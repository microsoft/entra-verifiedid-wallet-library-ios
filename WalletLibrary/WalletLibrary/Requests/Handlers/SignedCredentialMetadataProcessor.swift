/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum CredentialMetadataProcessorError: Error
{
    case No
}

/**
 * Utilities such as logger, mapper, httpclient (post private preview) that are configured in builder and
 * all of library will use.
 */
struct SignedCredentialMetadataProcessor
{
    private let tokenVerifier: TokenVerifying
    
    private let identifierDocumentResolver: IdentifierDocumentResolver
    
    private let rootOfTrustResolver: RootOfTrustResolver
    
    init(configuration: LibraryConfiguration)
    {
        self.tokenVerifier = TokenVerifier()
        self.identifierDocumentResolver = IdentifierDocumentResolver(configuration: configuration)
        self.rootOfTrustResolver = LinkedDomainResolver(configuration: configuration)
    }
    
    func process(signedMetadata: String,
                 credentialIssuer: String) async throws -> RootOfTrust
    {
        guard let signedMetadataToken = SignedMetadata(from: signedMetadata) else
        {
            throw CredentialMetadataProcessorError.No
        }
        
        guard let kid = signedMetadataToken.getKeyId() else
        {
            throw CredentialMetadataProcessorError.No
        }
        
        let identifierDocument = try await identifierDocumentResolver.resolve(identifier: kid.did)
        
        guard let publicKey = identifierDocument.getJWK(id: kid.keyId) else
        {
            throw CredentialMetadataProcessorError.No
        }
        
        try validateSignature(signedMetadata: signedMetadataToken,
                              using: publicKey)
        
        try signedMetadataToken.validateClaims(expectedSubject: credentialIssuer,
                                               expectedIssuer: kid.did)
        
        return try await rootOfTrustResolver.resolve(using: identifierDocument)
    }
    
    private func validateSignature(signedMetadata: SignedMetadata, using key: JWK) throws
    {
        do
        {
            let isValid = try tokenVerifier.verify(token: signedMetadata,
                                                   usingPublicKey: key)
            
            if !isValid
            {
                throw VerifiedIdError(message: "", code: "")
            }
        }
        catch
        {
            throw error
        }
    }
}
