/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum CredentialMetadataProcessorError: Error
{
    case No
}

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

struct SignedCredentialMetadataProcessor
{
    private let tokenVerifier: TokenVerifying
    
    private let identifierDocumentResolver: IdentifierDocumentResolver
    
    private let rootOfTrustResolver: RootOfTrustResolver
    
    init(tokenVerifier: TokenVerifying,
         identifierDocumentResolver: IdentifierDocumentResolver,
         rootOfTrustResolver: RootOfTrustResolver)
    {
        self.tokenVerifier = tokenVerifier
        self.identifierDocumentResolver = identifierDocumentResolver
        self.rootOfTrustResolver = rootOfTrustResolver
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

struct SignedMetadataTokenClaims: Claims
{
    let sub: String?
    
    let iss: String?
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
    
    func validateClaims(expectedSubject: String,
                        expectedIssuer: String) throws
    {
        if expectedIssuer != content.iss
        {
            throw TokenValidationError.InvalidProperty(content.iss, expected: expectedIssuer)
        }
        
        if expectedSubject != content.sub
        {
            throw TokenValidationError.InvalidProperty(content.sub, expected: expectedSubject)
        }
        
        try validateIatAndExp()
    }
}

extension JwsToken
{
    func validateIatAndExp() throws
    {
        guard let exp = content.exp else 
        { 
            throw TokenValidationError.PropertyNotPresent("exp")
        }
        
        guard let iat = content.iat else
        {
            throw TokenValidationError.PropertyNotPresent("iat")
        }
        
        guard getCurrentTimeInSecondsWithDelay() > exp else
        {
            throw TokenValidationError.TokenHasExpired
        }
        
        guard getCurrentTimeInSecondsWithDelay() < iat else
        {
            throw TokenValidationError.IatHasNotOccurred
        }
    }
    
    private func getCurrentTimeInSecondsWithDelay() -> Double {
        let currentTimeInSeconds = (Date().timeIntervalSince1970).rounded(.down)
        return currentTimeInSeconds - Double(300)
    }
}

enum TokenValidationError: Error
{
    case InvalidProperty(String?, expected: String)
    case PropertyNotPresent(String)
    case TokenHasExpired
    case IatHasNotOccurred
}

struct TokenHeaderKeyId
{
    let did: String
    
    let keyId: String
}


