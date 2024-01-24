/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

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
    
    private let openIdResponder: OpenIdResponder
    
    private let manifestResolver: ManifestResolver
    
    private let verifiedIdRequester: VerifiedIdRequester
    
    /// TODO: post private preview, manifest resolving and verified id requester will be handled by processors.
    init(configuration: LibraryConfiguration,
         openIdResponder: OpenIdResponder,
         manifestResolver: ManifestResolver,
         verifiableCredentialRequester: VerifiedIdRequester) {
        self.configuration = configuration
        self.openIdResponder = openIdResponder
        self.manifestResolver = manifestResolver
        self.verifiedIdRequester = verifiableCredentialRequester
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
        
        return handlePresentationRequest(requestContent: requestContent, rawRequest: request)
    }
    
    private func handleIssuanceRequest(from presentationRequestContent: PresentationRequestContent) async throws -> any VerifiedIdIssuanceRequest {
        
        guard let verifiedIdRequirement = presentationRequestContent.requirement as? VerifiedIdRequirement else {
            throw OpenIdRequestHandlerError.unableToCastRequirementToVerifiedIdRequirement
        }
        
        guard let issuanceOption = verifiedIdRequirement.issuanceOptions.first as? VerifiedIdRequestURL else {
            throw OpenIdRequestHandlerError.noIssuanceOptionsPresentToCreateIssuanceRequest
        }
        
        var rawContract: any RawManifest
        do {
            rawContract = try await manifestResolver.resolve(with: issuanceOption.url)
        } catch {
            await sendManifestResolutionErrorResult(callbackUrl: presentationRequestContent.callbackUrl,
                                                    state: presentationRequestContent.requestState)
            throw error
        }
        
        let issuanceRequestContent = try createIssuanceRequestContent(rawContract: rawContract,
                                                                      requestContent: presentationRequestContent)
        let issuanceResponseContainer = try IssuanceResponseContainer(from: rawContract, input: issuanceOption)
        
        return ContractIssuanceRequest(content: issuanceRequestContent,
                                       issuanceResponseContainer: issuanceResponseContainer,
                                       verifiedIdRequester: verifiedIdRequester,
                                       configuration: configuration)
    }
    
    private func createIssuanceRequestContent(rawContract: any RawManifest,
                                              requestContent: PresentationRequestContent) throws -> IssuanceRequestContent {
        
        var issuanceRequestContent = try configuration.mapper.map(rawContract)
        
        issuanceRequestContent.add(requestState: requestContent.requestState)
        issuanceRequestContent.add(issuanceResultCallbackUrl: requestContent.callbackUrl)
        
        if let did = try? configuration.identifierManager.fetchOrCreateMasterIdentifier().longFormDid,
           let nonce = NonceProcessor().createNonce(fromIdentifier: did)
        {
            issuanceRequestContent.addNonceToIdTokenRequirementIfPresent(nonce: nonce)
        }
        
        if let injectedIdToken = requestContent.injectedIdToken {
            issuanceRequestContent.addRequirement(from: injectedIdToken)
        }
        
        return issuanceRequestContent
    }
    
    private func sendManifestResolutionErrorResult(callbackUrl: URL, state: String) async {
        do {
            let issuanceErrorResult = IssuanceCompletionResponse(wasSuccessful: false,
                                                                 withState: state,
                                                                 andDetails: .fetchContractError)
            try await self.verifiedIdRequester.send(result: issuanceErrorResult, to: callbackUrl)
        } catch {
            configuration.logger.logError(message: "Unable to send Issuance Result to callback. Error: \(String(describing: error))")
        }
    }
    
    private func handlePresentationRequest(requestContent: PresentationRequestContent,
                                           rawRequest: any OpenIdRawRequest) -> any VerifiedIdPresentationRequest {
        return OpenIdPresentationRequest(content: requestContent,
                                         rawRequest: rawRequest,
                                         openIdResponder: openIdResponder,
                                         configuration: configuration)
    }
}
