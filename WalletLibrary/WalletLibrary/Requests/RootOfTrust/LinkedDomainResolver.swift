/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Allows a different way of resolving the root of trust (aka Linked Domain Result)
/// that can be injected into Issuance and Presentation Service.
struct LinkedDomainResolver: RootOfTrustResolver
{
    private let linkedDomainService: LinkedDomainService
    
    private let configuration: LibraryConfiguration
    
    init(linkedDomainService: LinkedDomainService,
         configuration: LibraryConfiguration)
    {
        self.linkedDomainService = linkedDomainService
        self.configuration = configuration
    }
    
    func resolve(using identifier: Any) async throws -> RootOfTrust
    {
        guard let identifier = identifier as? IdentifierDocument else
        {
            throw VerifiedIdError(message: "", code: "")
        }
        
        let linkedDomain = try await linkedDomainService.validateLinkedDomain(from: identifier)
        return try configuration.mapper.map(linkedDomain)
    }
}

struct IdentifierDocumentResolver
{
    private let identifierNetworkCalls: DIDDocumentNetworkCalls
    
    init(identifierNetworkCalls: DIDDocumentNetworkCalls) 
    {
        self.identifierNetworkCalls = identifierNetworkCalls
    }
    
    func resolve(identifier: String) async throws -> IdentifierDocument
    {
        return try await identifierNetworkCalls.getDocument(from: identifier)
    }
}

struct SignedMetadataValidator
{
    private let tokenVerifier: TokenVerifying
    
    init(tokenVerifier: TokenVerifying = TokenVerifier()) {
        self.tokenVerifier = tokenVerifier
    }
    
    func validate(signedMetadata: SignedMetadata, using key: JWK) throws
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

struct CredentialMetadataValidator
{
    private let tokenVerifier: TokenVerifying
    
    private let identifierDocumentResolver: IdentifierDocumentResolver
    
    init(tokenVerifier: TokenVerifying,
         identifierDocumentResolver: IdentifierDocumentResolver)
    {
        self.tokenVerifier = tokenVerifier
        self.identifierDocumentResolver = identifierDocumentResolver
    }
    
    func validate(credentialMetadata: CredentialMetadata) async throws
    {
        guard let signedMetadata = credentialMetadata.signed_metadata,
              let signedMetadataToken = SignedMetadata(from: signedMetadata) else
        {
            return
        }
        
        let signedMetadataValidator = SignedMetadataValidator()
        
        guard let kid = signedMetadataToken.getKeyId() else
        {
            return
        }
        
        let identifierDocument = try await identifierDocumentResolver.resolve(identifier: kid.did)
        
        guard let publicKey = identifierDocument.getJWK(id: kid.keyId) else
        {
            return
        }
        
        try signedMetadataValidator.validate(signedMetadata: signedMetadataToken,
                                             using: publicKey)
    }
    
    private func validate(signedMetadata: SignedMetadata, using key: JWK) throws
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

struct SignedMetadataTokenClaims: Claims
{
    
}

typealias SignedMetadata = JwsToken<SignedMetadataTokenClaims>

extension SignedMetadata
{
    func getKeyId() -> TokenHeaderKeyId?
    {
        guard let components = headers.keyId?.split(separator: "#",
                                                    maxSplits: 1,
                                                    omittingEmptySubsequences: true) else
        {
            return nil
        }
        
        return TokenHeaderKeyId(did: String(components[0]),
                                keyId: String(components[1]))
    }
}

struct TokenHeaderKeyId
{
    let did: String
    
    let keyId: String
}


