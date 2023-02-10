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
    
    init(mockHandleRequest: (() throws -> any VerifiedIdRequest)? = nil) {
        self.mockHandleRequest = mockHandleRequest
    }
    
    func handleRequest<RawRequest>(from: RawRequest) async throws -> any VerifiedIdRequest {
        
        guard let mockHandleRequest = mockHandleRequest else {
            throw MockHandlerError.nilMockHandlerMethod
        }
        
        return try mockHandleRequest()
    }
}
