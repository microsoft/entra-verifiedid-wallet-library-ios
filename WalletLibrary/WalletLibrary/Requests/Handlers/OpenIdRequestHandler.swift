/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum OpenIdRequestHandlerError: Error {
    case unsupportedRawRequestType
    case noIssuanceOptionsPresentToCreateIssuanceRequest
    case unableToCaseRequirementToVerifiedIdRequirement
}

/**
 * Handles a raw Open Id request and configures a VeriifedIdRequest object.
 * Post Private Preview TODO: add processors to support multiple profiles of open id.
 */
struct OpenIdRequestHandler: RequestHandling {
    
    private let configuration: LibraryConfiguration
    
    private let manifestResolver: ManifestResolver
    
    private let verifiableCredentialRequester: VerifiableCredentialRequester
    
    /// TODO: post private preview, manifest resolving and verified id requester will be handled by processors.
    init(configuration: LibraryConfiguration,
         manifestResolver: ManifestResolver,
         verifiableCredentialRequester: VerifiableCredentialRequester) {
        self.configuration = configuration
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
    
    private func handleIssuanceRequest(from requestContent: VerifiedIdRequestContent) async throws -> any VerifiedIdIssuanceRequest {
        
        guard let verifiedIdRequirement = requestContent.requirement as? VerifiedIdRequirement else {
            throw OpenIdRequestHandlerError.unableToCaseRequirementToVerifiedIdRequirement
        }
        
        guard let issuanceOption = verifiedIdRequirement.issuanceOptions.first as? VerifiedIdRequestURL else {
            throw OpenIdRequestHandlerError.noIssuanceOptionsPresentToCreateIssuanceRequest
        }
        
        let rawContract = try await manifestResolver.resolve(with: issuanceOption.url)
        
        
        let issuanceResponseContainer = try IssuanceResponseContainer(from: rawContract, input: issuanceOption)
        /// TODO: add logic here to add PinRequirement to ContractIssuanceRequest if it exists.
        let issuanceRequestContent = try configuration.mapper.map(rawContract)
        return ContractIssuanceRequest(content: issuanceRequestContent,
                                       issuanceResponseContainer: issuanceResponseContainer,
                                       verifiableCredentialRequester: verifiableCredentialRequester,
                                       configuration: configuration)
    }
    
    private func handlePresentationRequest(from requestContent: VerifiedIdRequestContent) throws -> any VerifiedIdPresentationRequest {
        return OpenIdPresentationRequest(content: requestContent, configuration: configuration)
    }
}
