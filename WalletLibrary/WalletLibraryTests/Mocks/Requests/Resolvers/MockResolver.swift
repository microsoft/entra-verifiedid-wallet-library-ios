/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockResolver: RequestResolving {
    
    enum MockResolverError: Error {
        case nilMockResolveMethod
    }
    
    let canResolveUsingHandler: ((RequestHandling) -> Bool)?
    
    let canResolveUsingInput: Bool
    
    let mockResolve: ((VerifiedIdClientInput) -> RawRequest)?
    
    init(canResolveUsingInput: Bool,
         canResolveUsingHandler: ((RequestHandling) -> Bool)? = nil,
         mockResolve: ((VerifiedIdClientInput) -> RawRequest)? = nil) {
        self.canResolveUsingHandler = canResolveUsingHandler
        self.canResolveUsingInput = canResolveUsingInput
        self.mockResolve = mockResolve
    }
    
    func canResolve(using handler: RequestHandling) -> Bool {
        return canResolveUsingHandler?(handler) ?? false
    }
    
    func canResolve(input: VerifiedIdClientInput) -> Bool {
        canResolveUsingInput
    }
    
    func resolve(input: VerifiedIdClientInput) async throws -> RawRequest {
        
        guard let mockResolve = mockResolve else {
            throw MockResolverError.nilMockResolveMethod
        }
        
        return mockResolve(input)
    }
}