/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockResolver: RequestResolving {
    
    enum MockResolverError: Error {
        case nilMockResolveMethod
    }
    
    let canResolveUsingHandler: ((any RequestHandling) -> Bool)?
    
    let canResolveUsingInput: Bool
    
    let mockResolve: ((VerifiedIdRequestInput) throws -> RawRequest)?
    
    init(canResolveUsingInput: Bool,
         canResolveUsingHandler: ((any RequestHandling) -> Bool)? = nil,
         mockResolve: ((VerifiedIdRequestInput) throws -> RawRequest)? = nil) {
        self.canResolveUsingHandler = canResolveUsingHandler
        self.canResolveUsingInput = canResolveUsingInput
        self.mockResolve = mockResolve
    }
    
    func canResolve(using handler: any RequestHandling) -> Bool {
        return canResolveUsingHandler?(handler) ?? false
    }
    
    func canResolve(input: VerifiedIdRequestInput) -> Bool {
        canResolveUsingInput
    }
    
    func resolve(input: VerifiedIdRequestInput) async throws -> MockRawRequest {
        
        guard let mockResolve = mockResolve else {
            throw MockResolverError.nilMockResolveMethod
        }
        
        return try mockResolve(input)
    }
}
