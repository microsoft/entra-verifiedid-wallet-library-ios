/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

internal protocol InternalNetworkOperation: NetworkOperation & InternalOperation {}

protocol NetworkOperation {
    associatedtype ResponseBody
    
    func fire() async throws -> ResponseBody
}

protocol InternalOperation {
    associatedtype Decoder: Decoding
    associatedtype ResponseBody where Decoder.ResponseBody == ResponseBody
    
    var decoder: Decoder { get }
    var successHandler: SuccessHandler { get }
    var failureHandler: FailureHandler { get }
    var retryHandler: RetryHandler { get }
    var urlSession: URLSession { get }
    var urlRequest: URLRequest { get set }
    var correlationVector: VerifiedIdCorrelationHeader? { get set }
    var sdkLog: VCSDKLog { get }
}

extension InternalNetworkOperation {
    
    var successHandler: SuccessHandler {
        return SimpleSuccessHandler()
    }
    
    var failureHandler: FailureHandler {
        return SimpleFailureHandler()
    }
    
    var retryHandler: RetryHandler {
        return NoRetry()
    }
    
    var sdkLog: VCSDKLog {
        return VCSDKLog.sharedInstance
    }
    
    func fire() async throws -> ResponseBody {
        
        // Adds library version header to all network calls.
        var urlRequest = self.urlRequest
        urlRequest.setValue("iOS/\(WalletLibraryVersion.Version)", forHTTPHeaderField: Constants.WALLET_LIBRARY_HEADER)
        
        if let cv = correlationVector {
            cv.update()
            urlRequest.setValue(cv.value, forHTTPHeaderField: cv.name)
            
            sdkLog.logInfo(message: "Correlation Vector for \(String(describing: self)): \(cv.value)")
        }
        
        return try await retryHandler.onRetry { [self] in
            try await call(urlRequest: urlRequest)
        }
    }
    
    private func call(urlRequest: URLRequest) async throws -> ResponseBody {
        let (data, response) = try await logNetworkTime(name: String(describing: Self.self),
                                                        correlationVector: correlationVector) { [self] in
            try await urlSession.data(for: urlRequest)
        }
        
        return try handleResponse(data: data, response: response)
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws -> ResponseBody {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.unableToParseData
        }
        
        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
            return try successHandler.onSuccess(data: data, decodeWith: self.decoder)
        }
        
        throw try failureHandler.onFailure(data: data, response: httpResponse)
    }
}
