/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

enum PresentationServiceError: Error {
    case inputStringNotUri
    case noKeysSavedForIdentifier
    case noQueryParametersOnUri
    case noValueForRequestUriQueryParameter
    case noRequestUriQueryParameter
    case unableToCastToPresentationResponseContainer
    case unableToFetchIdentifier
    case noKeyIdInRequestHeader
    case noPublicKeysInIdentifierDocument
    case noIssuerIdentifierInRequest
}

class PresentationService {
    
    let formatter: PresentationResponseFormatting
    let presentationApiCalls: PresentationNetworking
    private let didDocumentDiscoveryApiCalls: DiscoveryNetworking
    private let requestValidator: RequestValidating
    private let linkedDomainService: LinkedDomainService
    private let identifierService: IdentifierManager
    private let sdkLog: VCSDKLog
    
    convenience init(correlationVector: VerifiedIdCorrelationHeader? = nil,
                     identifierService: IdentifierManager?,
                     rootOfTrustResolver: RootOfTrustResolver?,
                     urlSession: URLSession) {
        self.init(formatter: PresentationResponseFormatter(sdkLog: VCSDKLog.sharedInstance),
                  presentationApiCalls: PresentationNetworkCalls(correlationVector: correlationVector,
                                                                 urlSession: urlSession),
                  didDocumentDiscoveryApiCalls: DIDDocumentNetworkCalls(correlationVector: correlationVector,
                                                                        urlSession: urlSession),
                  requestValidator: PresentationRequestValidator(),
                  linkedDomainService: LinkedDomainService(correlationVector: correlationVector,
                                                           rootOfTrustResolver: rootOfTrustResolver,
                                                           urlSession: urlSession),
                  identifierService: identifierService ?? IdentifierService(),
                  sdkLog: VCSDKLog.sharedInstance)
    }
    
    init(formatter: PresentationResponseFormatting,
         presentationApiCalls: PresentationNetworking,
         didDocumentDiscoveryApiCalls: DiscoveryNetworking,
         requestValidator: RequestValidating,
         linkedDomainService: LinkedDomainService,
         identifierService: IdentifierManager,
         sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.formatter = formatter
        self.presentationApiCalls = presentationApiCalls
        self.didDocumentDiscoveryApiCalls = didDocumentDiscoveryApiCalls
        self.requestValidator = requestValidator
        self.linkedDomainService = linkedDomainService
        self.identifierService = identifierService
        self.sdkLog = sdkLog
    }
    
    func getRequest(usingUrl urlStr: String) async throws -> PresentationRequest {
        return try await logTime(name: "Presentation getRequest") {
            let requestUri = try self.getRequestUri(from: urlStr)
            let request = try await self.presentationApiCalls.getRequest(withUrl: requestUri)
            return try await self.validate(request: request)
        }
    }
    
    func validate(request: PresentationRequestToken) async throws -> PresentationRequest {
        
        let document = try await self.getIdentifierDocument(from: request)
        
        guard let publicKeys = document.verificationMethod else
        {
            throw PresentationServiceError.noPublicKeysInIdentifierDocument
        }
        
        try self.requestValidator.validate(request: request, usingKeys: publicKeys)
        let result = try await self.linkedDomainService.validateLinkedDomain(from: document)
        return PresentationRequest(from: request, linkedDomainResult: result)
    }
    
    func send(response: PresentationResponseContainer, 
              additionalHeaders: [String: String]? = nil) async throws {
        try await logTime(name: "Presentation sendResponse") {
            let formattedResponse = try self.formatPresentationResponse(response: response)
            try await self.presentationApiCalls.sendResponse(usingUrl: response.audienceUrl,
                                                             withBody: formattedResponse,
                                                             additionalHeaders: additionalHeaders)
        }
    }
    
    private func getRequestUri(from urlStr: String) throws -> String {
        
        guard let urlComponents = URLComponents(string: urlStr) else { throw PresentationServiceError.inputStringNotUri }
        guard let queryItems = urlComponents.percentEncodedQueryItems else { throw PresentationServiceError.noQueryParametersOnUri }
        
        for queryItem in queryItems {
            if queryItem.name == ServicesConstants.REQUEST_URI {
                guard let value = queryItem.value?.removingPercentEncoding
                else { throw PresentationServiceError.noValueForRequestUriQueryParameter }
                return value
            }
        }
        
        throw PresentationServiceError.noRequestUriQueryParameter
    }
    
    private func getIdentifierDocument(from token: PresentationRequestToken) async throws -> IdentifierDocument {
        let did = try getDIDFromHeader(request: token)
        return try await didDocumentDiscoveryApiCalls.getDocument(from: did)
    }
    
    private func getDIDFromHeader(request: PresentationRequestToken) throws -> String {
        
        guard let kid = request.headers.keyId?.split(separator: ServicesConstants.FRAGMENT_SEPARATOR),
              let did = kid.first else {
            
            throw PresentationServiceError.noKeyIdInRequestHeader
        }
        
        return String(did)
    }
    
    private func formatPresentationResponse(response: PresentationResponseContainer) throws -> PresentationResponse {
        let identifier = try identifierService.fetchOrCreateMasterIdentifier()
        sdkLog.logVerbose(message: "Signing Presentation Response with Identifier")
        return try self.formatter.format(response: response,
                                         usingIdentifier: identifier)
    }
}
