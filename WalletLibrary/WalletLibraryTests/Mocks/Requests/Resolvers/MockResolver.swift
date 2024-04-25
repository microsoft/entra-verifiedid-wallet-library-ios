/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockResolver: RequestResolving {
    
    enum MockResolverError: Error {
        case nilMockResolveMethod
    }
    
    var preferHeaders: [String] = []
    
    let canResolveUsingInput: Bool
    
    let mockResolve: ((VerifiedIdRequestInput) throws -> Any)?
    
    init(canResolveUsingInput: Bool,
         mockResolve: ((VerifiedIdRequestInput) throws -> Any)? = nil) {
        self.canResolveUsingInput = canResolveUsingInput
        self.mockResolve = mockResolve
    }
    
    func canResolve(input: VerifiedIdRequestInput) -> Bool {
        canResolveUsingInput
    }
    
    func resolve(input: VerifiedIdRequestInput) async throws -> Any {
        
        guard let mockResolve = mockResolve else {
            throw MockResolverError.nilMockResolveMethod
        }
        
        return try mockResolve(input)
    }
}
