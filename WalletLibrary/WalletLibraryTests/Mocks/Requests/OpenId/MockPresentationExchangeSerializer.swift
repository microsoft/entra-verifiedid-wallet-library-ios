/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockPresentationExchangeSerializer: PresentationExchangeSerializer
{
    private let expectedSerializationErrorToThrow: Error?
    
    private let expectedBuildErrorToThrow: Error?
    
    private let expectedBuildResult: PresentationResponse?
    
    init(expectedSerializationErrorToThrow: Error? = nil,
         expectedBuildErrorToThrow: Error? = nil,
         expectedBuildResult: PresentationResponse? = nil) throws
    {
        self.expectedSerializationErrorToThrow = expectedSerializationErrorToThrow
        self.expectedBuildErrorToThrow = expectedBuildErrorToThrow
        self.expectedBuildResult = expectedBuildResult
        let mockRequest = MockOpenIdRawRequest(raw: nil)
        try super.init(request: mockRequest, libraryConfiguration: LibraryConfiguration())
    }
    
    override func serialize<T>(requirement: any Requirement, verifiedIdSerializer: any VerifiedIdSerializing<T>) throws
    {
        if let expectedSerializationErrorToThrow = expectedSerializationErrorToThrow
        {
            throw expectedSerializationErrorToThrow
        }
    }
    
    override func build() throws -> PresentationResponse
    {
        if let expectedBuildErrorToThrow = expectedBuildErrorToThrow
        {
            throw expectedBuildErrorToThrow
        }
        else if let result = expectedBuildResult
        {
            return result
        }
        
        let header = Header(type: "type", algorithm: "alg", jsonWebKey: "key", keyId: "kid")
        let claims = PresentationResponseClaims(nonce: "nonce")
        let idToken = PresentationResponseToken(headers: header, content: claims)!
        return PresentationResponse(idToken: idToken, vpTokens: [], state: "state")
    }
}

