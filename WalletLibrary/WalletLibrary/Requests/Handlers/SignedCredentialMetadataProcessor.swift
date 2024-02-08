/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum CredentialMetadataProcessorError: Error
{
    case No
}

/**
 * Defines a structure for processing signed credential metadata.
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
    
    /// Processes the signed metadata, verifying its integrity and authenticity, and resolving the root of trust.
    /// - Parameters:
    ///   - signedMetadata: A string representation of the signed metadata, expected to be in JSON Web Token format.
    ///   - credentialIssuer: The credential issuer property from the Credential Metadata.
    func process(signedMetadata: String,
                 credentialIssuer: String) async throws -> RootOfTrust
    {
        guard let signedMetadataToken = SignedMetadata(from: signedMetadata) else
        {
            let errorMessage = "Signed Metadata is not a JSON Web Token."
            throw OpenId4VCIProtocolValidationError.MalformedSignedMetadataToken(message: errorMessage)
        }
        
        guard let kid = signedMetadataToken.getKeyId() else
        {
            let errorMessage = "Unable to extract Key Id from Signed Metadata Token."
            throw OpenId4VCIProtocolValidationError.MalformedSignedMetadataToken(message: errorMessage)
        }
        
        let identifierDocument = try await identifierDocumentResolver.resolve(identifier: kid.did)
        
        guard let publicKey = identifierDocument.getJWK(id: kid.keyId) else
        {
            let errorMessage = "Key Id not defined in Identifier Document."
            throw OpenId4VCIProtocolValidationError.MalformedSignedMetadataToken(message: errorMessage)
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
                let errorMessage = "The signature on the Signed Metadata Token is not valid."
                throw OpenId4VCIProtocolValidationError.MalformedSignedMetadataToken(message: errorMessage)
            }
        }
        catch
        {
            throw OpenId4VCIProtocolValidationError.MalformedSignedMetadataToken(message: "Unable to verify signature",
                                                                                 error: error)
        }
    }
}
