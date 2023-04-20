/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

class SimpleFailureHandler: FailureHandler {
    
    private let sdkLog: VCSDKLog
    
    init(sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.sdkLog = sdkLog
    }
    
    func onFailure(data: Data, response: HTTPURLResponse) throws -> NetworkingError {
        
        guard let responseBody = String(data: data, encoding: .utf8) else {
            throw NetworkingError.unableToParseData
        }
        
        var error: NetworkingError
        switch response.statusCode {
        case 400:
            error = NetworkingError.badRequest(withBody: responseBody, statusCode: response.statusCode)
        case 401:
            error = NetworkingError.unauthorized(withBody: responseBody, statusCode: response.statusCode)
        case 403:
            error = NetworkingError.forbidden(withBody: responseBody, statusCode: response.statusCode)
        case 404:
            error = NetworkingError.notFound(withBody: responseBody, statusCode: response.statusCode)
        case 500...599:
            error = NetworkingError.serverError(withBody: responseBody, statusCode: response.statusCode)
        default:
            error = NetworkingError.unknownNetworkingError(withBody: responseBody, statusCode: response.statusCode)
        }
        
        self.logNetworkingError(error: error)
        return error
    }
    
    private func logNetworkingError(error: NetworkingError) {
        sdkLog.logError(message: """
            Networking Error: \(error.self)
            """)
    }
}
