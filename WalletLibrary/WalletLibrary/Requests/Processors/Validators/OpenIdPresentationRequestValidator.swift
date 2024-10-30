/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/// A validator class responsible for validating OpenID presentation requests.
/// It interacts with various services to ensure the request is properly verified
/// and trusted before proceeding with further actions.
class OpenIdPresentationRequestValidator: OpenIdRequestValidating
{
    /// API for making discovery calls to fetch DID documents. TODO use new networking layer for this.
    private let didDocumentDiscoveryApiCalls: DiscoveryNetworking
    
    /// Validator for checking the authenticity and structure of presentation requests.
    private let requestValidator: RequestValidating
    
    /// Service for validating the linked domain associated with a DID document.
    private let linkedDomainService: LinkedDomainService
    
    convenience init(correlationVector: VerifiedIdCorrelationHeader? = nil,
                     rootOfTrustResolver: RootOfTrustResolver?,
                     urlSession: URLSession) 
    {
        self.init(didDocumentDiscoveryApiCalls: DIDDocumentNetworkCalls(correlationVector: correlationVector,
                                                                        urlSession: urlSession),
                  requestValidator: PresentationRequestValidator(),
                  linkedDomainService: LinkedDomainService(correlationVector: correlationVector,
                                                           rootOfTrustResolver: rootOfTrustResolver,
                                                           urlSession: urlSession))
    }
    
    init(didDocumentDiscoveryApiCalls: DiscoveryNetworking,
         requestValidator: RequestValidating,
         linkedDomainService: LinkedDomainService)
    {
        self.didDocumentDiscoveryApiCalls = didDocumentDiscoveryApiCalls
        self.requestValidator = requestValidator
        self.linkedDomainService = linkedDomainService
    }
    
    /// Validates the given presentation request token by checking its identifier document,
    /// verifying the associated public keys, and confirming the linked domain.
    ///
    /// - Parameter request: The token representing the presentation request.
    /// - Returns: A validated `PresentationRequest` if successful.
    /// - Throws: An error if validation fails at any step.
    func validateRequest(data: Data) async throws -> any OpenIdRawRequest
    {
        let request = try PresentationRequestDecoder().decode(data: data)
        let document = try await self.getIdentifierDocument(from: request)
        
        guard let publicKeys = document.verificationMethod else
        {
            throw VerifiedIdErrors.MalformedInput(message: "No Public Keys in Identifier Document.").error
        }
        
        try self.requestValidator.validate(request: request, usingKeys: publicKeys)
        let result = try await self.linkedDomainService.validateLinkedDomain(from: document)
        return PresentationRequest(from: request, linkedDomainResult: result)
    }
    
    private func getIdentifierDocument(from token: PresentationRequestToken) async throws -> IdentifierDocument 
    {
        let did = try getDIDFromHeader(request: token)
        return try await didDocumentDiscoveryApiCalls.getDocument(from: did)
    }
    
    private func getDIDFromHeader(request: PresentationRequestToken) throws -> String 
    {
        
        guard let kid = request.headers.keyId?.split(separator: ServicesConstants.FRAGMENT_SEPARATOR),
              let did = kid.first else 
        {
            throw VerifiedIdErrors.MalformedInput(message: "No DID in request header.").error
        }
        
        return String(did)
    }
}
