/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Processes a raw Open Id request and configures a VeriifedIdRequest object.
 */
public class OpenIdRequestProcessor: RequestProcessing
{
    public typealias RawRequestType = Dictionary<String, Any>
    
    public var requestProcessorExtensions: [any RequestProcessorExtendable] = []
    
    private let configuration: LibraryConfiguration
    
    private let openIdResponder: OpenIdResponder
    
    private let manifestResolver: ManifestResolver
    
    private let verifiedIdRequester: VerifiedIdRequester
    
    init(configuration: LibraryConfiguration,
         openIdResponder: OpenIdResponder,
         manifestResolver: ManifestResolver,
         verifiableCredentialRequester: VerifiedIdRequester) 
    {
        self.configuration = configuration
        self.openIdResponder = openIdResponder
        self.manifestResolver = manifestResolver
        self.verifiedIdRequester = verifiableCredentialRequester
    }
    
    func canProcess(rawRequest: Any) -> Bool
    {
        // TODO: once VC SDK logic is moved to handler and new resolver logic is implemented,
        // reimplement with new constraints.
        return rawRequest is any OpenIdRawRequest
    }
    
    /// Create a VeriifiedIdRequest based on the Open Id raw request given.
    func process(rawRequest: Any) async throws -> any VerifiedIdRequest
    {
        guard let request = rawRequest as? any OpenIdRawRequest else 
        {
            throw VerifiedIdErrors.MalformedInput(message: "Unsupported Raw Request Type: \(type(of: rawRequest))").error
        }
        
        let requestContent = try configuration.mapper.map(request)
        
        if request.type == .Issuance {
            return try await handleIssuanceRequest(from: requestContent)
        }
        
        return processPresentationRequest(requestContent: requestContent, rawRequest: request)
    }
    
    private func handleIssuanceRequest(from presentationRequestContent: PresentationRequestContent) async throws -> any VerifiedIdIssuanceRequest 
    {
        guard let verifiedIdRequirement = presentationRequestContent.requirement as? VerifiedIdRequirement else 
        {
            let message = "Unsupported requirement: \(type(of: presentationRequestContent.requirement))"
            throw VerifiedIdErrors.MalformedInput(message: message).error
        }
        
        guard let issuanceOption = verifiedIdRequirement.issuanceOptions.first as? VerifiedIdRequestURL else {
            let message = "No issuance options available on Presentation Request."
            throw VerifiedIdErrors.MalformedInput(message: message).error
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
           let nonce = NonceCreator().createNonce(fromIdentifier: did)
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
    
    private func processPresentationRequest(requestContent: PresentationRequestContent,
                                            rawRequest: any OpenIdRawRequest) -> any VerifiedIdPresentationRequest
    {
        if configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.ProcessorExtensionSupport)
        {
            return processPresentationRequestWithExtension(requestContent: requestContent,
                                                           rawRequest: rawRequest)
        }
        else
        {
            return OpenIdPresentationRequest(content: requestContent,
                                             rawRequest: rawRequest,
                                             openIdResponder: openIdResponder,
                                             configuration: configuration)
        }
    }
    
    private func processPresentationRequestWithExtension(requestContent: PresentationRequestContent,
                                                         rawRequest: any OpenIdRawRequest) -> any VerifiedIdPresentationRequest
    {
        var partial = VerifiedIdPartialRequest(requesterStyle: requestContent.style,
                                               requirement: requestContent.requirement,
                                               rootOfTrust: requestContent.rootOfTrust)
        
        if let primitiveClaims = rawRequest.primitiveClaims
        {
            partial = requestProcessorExtensions.reduce(partial) { (partial, ext) in
                self.parse(partial: partial,
                           requestProcessorExtension: ext,
                           rawRequest: primitiveClaims)
            }
        }
        
        return OpenIdPresentationRequest(partialRequest: partial,
                                         rawRequest: rawRequest,
                                         openIdResponder: openIdResponder,
                                         configuration: configuration)
        
    }
    
    private func parse<Extension: RequestProcessorExtendable>(partial: VerifiedIdPartialRequest,
                                                              requestProcessorExtension: Extension,
                                                              rawRequest: RawRequestType) -> VerifiedIdPartialRequest
    {
        if Extension.RequestProcessor.self == Self.self,
           let raw = rawRequest as? Extension.RequestProcessor.RawRequestType
        {
            return requestProcessorExtension.parse(rawRequest: raw,
                                                   request: partial)
        }
        
        return partial
    }
}
