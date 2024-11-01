/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockOpenIdRequestValidator: OpenIdRequestValidating
{
    
    private let expectedResult: MockOpenIdRawRequest
    
    private let expectedError: Error?
    
    init(expectedResult: MockOpenIdRawRequest? = nil, expectedError: Error? = nil)
    {
        self.expectedResult = expectedResult ?? MockOpenIdRawRequest(raw: nil)
        self.expectedError = expectedError
    }
    
    func validateRequest(data: Data) async throws -> any OpenIdRawRequest
    {
        if let error = expectedError
        {
            throw error
        }
        
        return expectedResult
    }
}
