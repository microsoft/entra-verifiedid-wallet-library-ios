/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol IssuanceNetworking {
    func getRequest(withUrl url: String) async throws -> SignedContract
    func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) async throws -> VerifiableCredential
    func sendCompletionResponse(usingUrl url: String, withBody body: IssuanceCompletionResponse) async throws
}

class IssuanceNetworkCalls: IssuanceNetworking {

    private let urlSession: URLSession
    private let correlationVector: VerifiedIdCorrelationHeader?
    
    init(correlationVector: VerifiedIdCorrelationHeader? = nil,
         urlSession: URLSession = URLSession.shared) {
        self.correlationVector = correlationVector
        self.urlSession = urlSession
    }
    
    func getRequest(withUrl url: String) async throws -> SignedContract {
        var operation = try FetchContractOperation(withUrl: url,
                                                   andCorrelationVector: correlationVector,
                                                   session: self.urlSession)
        return try await AsyncWrapper().wrap { operation.fire() }()
    }
    
    func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) async throws -> VerifiableCredential {
        var operation = try PostIssuanceResponseOperation(usingUrl: url,
                                                          withBody: body,
                                                          andCorrelationVector: correlationVector,
                                                          urlSession: self.urlSession)
        return try await AsyncWrapper().wrap { operation.fire() }()
    }
    
    func sendCompletionResponse(usingUrl url: String, withBody body: IssuanceCompletionResponse) async throws {
        var operation = try PostIssuanceCompletionResponseOperation(usingUrl: url,
                                                                    withBody: body,
                                                                    andCorrelationVector: correlationVector,
                                                                    urlSession: self.urlSession)
        let _ = try await AsyncWrapper().wrap { operation.fire() }()
    }
}
