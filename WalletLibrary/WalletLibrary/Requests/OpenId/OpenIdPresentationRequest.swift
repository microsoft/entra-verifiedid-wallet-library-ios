/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdPresentationRequestError: Error {
    case cancelPresentationRequestIsUnsupported
    case NoResponseURLOnRawRequest
}

/**
 * Presentation Requst that is Open Id specific.
 */
class OpenIdPresentationRequest: VerifiedIdPresentationRequest 
{
    /// The look and feel of the requester.
    let style: RequesterStyle
    
    /// The requirement needed to fulfill request.
    let requirement: Requirement
    
    /// The root of trust results between the request and the source of the request.
    let rootOfTrust: RootOfTrust
    
    /// The DID of the verifier
    let authority: String
    
    let nonce: String?
    
    private let rawRequest: any OpenIdRawRequest
    
    private let responder: OpenIdResponder
    
    private let configuration: LibraryConfiguration
    
    private var additionalHeaders: [String: String]?
    
    init(content: PresentationRequestContent,
         rawRequest: any OpenIdRawRequest,
         openIdResponder: OpenIdResponder,
         configuration: LibraryConfiguration) 
    {
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.rawRequest = rawRequest
        self.authority = rawRequest.authority
        self.nonce = rawRequest.nonce
        self.responder = openIdResponder
        self.configuration = configuration
    }
    
    init(partialRequest: VerifiedIdPartialRequest,
         rawRequest: any OpenIdRawRequest,
         openIdResponder: OpenIdResponder,
         configuration: LibraryConfiguration)
    {
        self.style = partialRequest.requesterStyle
        self.requirement = partialRequest.requirement
        self.rootOfTrust = partialRequest.rootOfTrust
        self.rawRequest = rawRequest
        self.authority = rawRequest.authority
        self.nonce = rawRequest.nonce
        self.responder = openIdResponder
        self.configuration = configuration
    }
    
    /// Whether or not the request is satisfied on client side.
    func isSatisfied() -> Bool {
        do {
            try requirement.validate().get()
            return true
        } catch {
            /// TODO: log error.
            return false
        }
    }
    
    func set(additionalHeaders: [String : String])
    {
        self.additionalHeaders = additionalHeaders
    }
    
    /// Completes the request and returns a Result object containing void if successful, and an error if not successful.
    func complete() async -> VerifiedIdResult<Void> {
        
        if configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.PresentationExchangeSerializationSupport)
        {
            return await completeWithProcessorExtensions()
        }
        
        return await VerifiedIdResult<Void>.getResult {
            var response = try PresentationResponseContainer(rawRequest: self.rawRequest)
            try response.add(requirement: self.requirement)
            try await self.responder.send(response: response, additionalHeaders: self.additionalHeaders)
        }
    }
    
    func completeWithProcessorExtensions() async -> VerifiedIdResult<Void> {
        return await VerifiedIdResult<Void>.getResult {
            
            guard let responseURL = self.rawRequest.responseURL else
            {
                throw VerifiedIdPresentationRequestError.NoResponseURLOnRawRequest
            }
            
            let serializer = VerifiableCredentialSerializer()
            let peSerializer = try PresentationExchangeSerializer(request: self.rawRequest,
                                                                  libraryConfiguration: self.configuration)
            try peSerializer.serialize(requirement: self.requirement,
                                       verifiedIdSerializer: serializer)
            let response = try peSerializer.build()
            _ = try await self.configuration.networking.post(requestBody: response,
                                                             url: responseURL,
                                                             PostPresentationResponseOperation.self,
                                                             additionalHeaders: self.additionalHeaders)
            
        }
    }
    
    /// Cancel the request with an optional message.
    func cancel(message: String?) async -> VerifiedIdResult<Void> {
        return VerifiedIdError(message: message ?? "User Canceled.", code: VerifiedIdErrors.ErrorCode.UserCanceled).result()
    }
}
