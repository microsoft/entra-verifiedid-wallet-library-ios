/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol PresentationNetworking {
    func getRequest(withUrl url: String) async throws -> PresentationRequestToken
    func sendResponse(usingUrl url: String, withBody body: PresentationResponse) async throws
}

class PresentationNetworkCalls: PresentationNetworking {

    private let urlSession: URLSession
    private let correlationVector: VerifiedIdCorrelationHeader?
    
    init(correlationVector: VerifiedIdCorrelationHeader? = nil,
         urlSession: URLSession = URLSession.shared) {
        self.correlationVector = correlationVector
        self.urlSession = urlSession
    }
    
    func getRequest(withUrl url: String) async throws -> PresentationRequestToken {
        var operation = try FetchPresentationRequestOperation(withUrl: url,
                                                              andCorrelationVector: correlationVector,
                                                              session: urlSession)
        return try await AsyncWrapper().wrap { operation.fire() }()
    }
    
    func sendResponse(usingUrl url: String, withBody body: PresentationResponse) async throws {
        var operation = try PostPresentationResponseOperation(usingUrl: url,
                                                              withBody: body,
                                                              andCorrelationVector: correlationVector,
                                                              urlSession: urlSession)
        let _ = try await AsyncWrapper().wrap { operation.fire() }()
    }
}

