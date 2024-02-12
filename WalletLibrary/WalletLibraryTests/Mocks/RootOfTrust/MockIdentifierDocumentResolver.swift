/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockIdentifierDocumentResolver: IdentifierDocumentResolving
{
    enum ExpectedError: Error
    {
        case expectedToBeThrown
    }
    
    private let mockResolve: ((String) throws -> IdentifierDocument)?
    
    init(mockResolve: ((String) throws -> IdentifierDocument)? = nil)
    {
        self.mockResolve = mockResolve
    }
    
    func resolve(identifier: String) async throws -> IdentifierDocument
    {
        if let mockResolve = mockResolve
        {
            return try mockResolve(identifier)
        }
        
        throw ExpectedError.expectedToBeThrown
    }
}
