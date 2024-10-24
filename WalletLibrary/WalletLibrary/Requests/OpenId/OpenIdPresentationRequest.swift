/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
    
    /// The nonce from the request.
    let nonce: String?
    
    private let rawRequest: any OpenIdRawRequest
    
    private let responder: OpenIdResponder
    
    private let configuration: LibraryConfiguration
    
    private let requestProcessorSerializer: RequestProcessorSerializing?
    
    private let verifiedIdSerializer: (any VerifiedIdSerializing)?
    
    init(partialRequest: VerifiedIdPartialRequest,
         rawRequest: any OpenIdRawRequest,
         openIdResponder: OpenIdResponder,
         configuration: LibraryConfiguration,
         requestProcessorSerializer: RequestProcessorSerializing,
         verifiedIdSerializer: any VerifiedIdSerializing)
    {
        self.style = partialRequest.requesterStyle
        self.requirement = partialRequest.requirement
        self.rootOfTrust = partialRequest.rootOfTrust
        self.rawRequest = rawRequest
        self.nonce = rawRequest.nonce
        self.responder = openIdResponder
        self.configuration = configuration
        self.requestProcessorSerializer = requestProcessorSerializer
        self.verifiedIdSerializer = verifiedIdSerializer
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
    
    /// Completes the request and returns a Result object containing void if successful, and an error if not successful.
    func complete() async -> VerifiedIdResult<Void> 
    {
            return await completeWithProcessorExtensions()
    }
    
    private func completeWithProcessorExtensions() async -> VerifiedIdResult<Void>
    {
        return await VerifiedIdResult<Void>.getResult {
            
            /// Only support Verifiable Credential Serializer for now.
            guard let verifiedIdSerializer = self.verifiedIdSerializer as? VerifiableCredentialSerializer else
            {
                throw PresentationExchangeError.MissingRequiredProperty(message: "Verifiable Credential Serializer is invalid or nil.")
            }
            
            /// Only support Presentation Exchange Serializer for now.
            guard let requestProcessorSerializer = self.requestProcessorSerializer as? PresentationExchangeSerializer else
            {
                throw PresentationExchangeError.MissingRequiredProperty(message: "Presentation Exchange Serializer is invalid or nil.")
            }
            
            guard let responseURL = self.rawRequest.responseURL else
            {
                throw PresentationExchangeError.MissingRequiredProperty(message: "Missing response URL on request.")
            }
            
            try requestProcessorSerializer.serialize(requirement: self.requirement,
                                                     verifiedIdSerializer: verifiedIdSerializer)
            let response = try requestProcessorSerializer.build()
            _ = try await self.configuration.networking.post(requestBody: response,
                                                             url: responseURL,
                                                             PostPresentationResponseOperation.self)
            
        }
    }
    
    /// Cancel the request with an optional message.
    func cancel(message: String?) async -> VerifiedIdResult<Void> {
        return VerifiedIdError(message: message ?? "User Canceled.", code: VerifiedIdErrors.ErrorCode.UserCanceled).result()
    }
}
