/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockHandler: RequestHandling {

    enum MockHandlerError: Error {
        case nilMockHandlerMethod
    }
    
    let mockHandleRequest: (() throws -> any VerifiedIdRequest)?
    
    let mockCanHandle: Bool
    
    init(mockCanHandle: Bool = false,
         mockHandleRequest: (() throws -> any VerifiedIdRequest)? = nil) {
        self.mockCanHandle = mockCanHandle
        self.mockHandleRequest = mockHandleRequest
    }
    
    func canHandle(_ object: Any) -> Bool {
        return mockCanHandle
    }
    
    func handleRequest<RawRequest>(from: RawRequest) async throws -> any VerifiedIdRequest {
        
        guard let mockHandleRequest = mockHandleRequest else {
            throw MockHandlerError.nilMockHandlerMethod
        }
        
        return try mockHandleRequest()
    }
}
