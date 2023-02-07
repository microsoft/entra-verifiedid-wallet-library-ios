/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockHandler: RequestHandling {
    
    enum MockHandlerError: Error {
        case nilMockHandlerMethod
    }
    
    let mockHandleRequest: (() -> any VerifiedIdRequest)?
    
    init(mockHandleRequest: (() -> any VerifiedIdRequest)? = nil) {
        self.mockHandleRequest = mockHandleRequest
    }
    
    func handleRequest(input: VerifiedIdClientInput, using resolver: RequestResolving) async throws -> any VerifiedIdRequest {
        
        guard let mockHandleRequest = mockHandleRequest else {
            throw MockHandlerError.nilMockHandlerMethod
        }
        
        return mockHandleRequest()
    }
}
