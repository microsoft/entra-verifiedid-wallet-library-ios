/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum OpenIdRequestHandlerError: Error {
    case unsupportedRawRequestType
    case noIssuanceOptionsPresentToCreateIssuanceRequest
    case unableToCastRequirementToVerifiedIdRequirement
}

/**
 * Handles a raw Open Id request and configures a VeriifedIdRequest object.
 * Post Private Preview TODO: add processors to support multiple profiles of open id.
 */
struct OpenIdRequestHandler: RequestHandling {
    
    private let configuration: LibraryConfiguration
    
    private let presentationRequestResponder: OpenIdForVCResponder
    
    private let manifestResolver: ManifestResolver
    
    private let verifiableCredentialRequester: VerifiedIdRequester
    
    /// TODO: post private preview, manifest resolving and verified id requester will be handled by processors.
    init(configuration: LibraryConfiguration,
         presentationRequestResponder: OpenIdForVCResponder,
         manifestResolver: ManifestResolver,
         verifiableCredentialRequester: VerifiedIdRequester) {
        self.configuration = configuration
        self.presentationRequestResponder = presentationRequestResponder
        self.manifestResolver = manifestResolver
        self.verifiableCredentialRequester = verifiableCredentialRequester
    }
    
    /// Create a VeriifiedIdRequest based on the Open Id raw request given.
    func handleRequest<RawRequest>(from request: RawRequest) async throws -> any VerifiedIdRequest {
        
        guard let request = request as? any OpenIdRawRequest else {
            throw OpenIdRequestHandlerError.unsupportedRawRequestType
        }
        
        let requestContent = try configuration.mapper.map(request)
        
        if request.type == .Issuance {
            return try await handleIssuanceRequest(from: requestContent)
        }
        
        return try handlePresentationRequest(from: requestContent)
    }
    
    private func handleIssuanceRequest(from requestContent: PresentationRequestContent) async throws -> any VerifiedIdIssuanceRequest {
        
        guard let verifiedIdRequirement = requestContent.requirement as? VerifiedIdRequirement else {
            throw OpenIdRequestHandlerError.unableToCastRequirementToVerifiedIdRequirement
        }
        
        guard let issuanceOption = verifiedIdRequirement.issuanceOptions.first as? VerifiedIdRequestURL else {
            throw OpenIdRequestHandlerError.noIssuanceOptionsPresentToCreateIssuanceRequest
        }
        
        let rawContract = try await manifestResolver.resolve(with: issuanceOption.url)
        
        let issuanceResponseContainer = try IssuanceResponseContainer(from: rawContract, input: issuanceOption)
        var issuanceRequestContent = try configuration.mapper.map(rawContract)
        
        if let injectedIdToken = requestContent.injectedIdToken {
            issuanceRequestContent.addRequirement(from: injectedIdToken)
        }
        
        return ContractIssuanceRequest(content: issuanceRequestContent,
                                       issuanceResponseContainer: issuanceResponseContainer,
                                       verifiedIdRequester: verifiableCredentialRequester,
                                       configuration: configuration)
    }
    
    private func handlePresentationRequest(from requestContent: PresentationRequestContent) throws -> any VerifiedIdPresentationRequest {
        return try OpenIdPresentationRequest(content: requestContent,
                                             openIdResponder: presentationRequestResponder,
                                             configuration: configuration)
    }
}
