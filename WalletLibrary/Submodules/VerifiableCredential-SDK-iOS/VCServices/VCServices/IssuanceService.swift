/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

enum IssuanceServiceError: Error {
    case noKeyIdInRequestHeader
    case unableToCastToPresentationResponseContainer
    case unableToFetchIdentifier
    case noPublicKeysInIdentifierDocument
}

class IssuanceService {
    
    let formatter: IssuanceResponseFormatting
    let apiCalls: IssuanceNetworking
    private let discoveryApiCalls: DiscoveryNetworking
    private let requestValidator: IssuanceRequestValidating
    private let identifierService: IdentifierManager
    private let linkedDomainService: LinkedDomainService
    private let sdkLog: VCSDKLog
    
    convenience init(correlationVector: VerifiedIdCorrelationHeader? = nil,
                     identifierManager: IdentifierManager? = nil,
                     rootOfTrustResolver: RootOfTrustResolver? = nil,
                     urlSession: URLSession) {
        self.init(formatter: IssuanceResponseFormatter(),
                  apiCalls: IssuanceNetworkCalls(correlationVector: correlationVector,
                                                 urlSession: urlSession),
                  discoveryApiCalls: DIDDocumentNetworkCalls(correlationVector: correlationVector,
                                                             urlSession: urlSession),
                  requestValidator: IssuanceRequestValidator(),
                  identifierService: identifierManager ?? IdentifierService(),
                  linkedDomainService: LinkedDomainService(correlationVector: correlationVector,
                                                           rootOfTrustResolver: rootOfTrustResolver,
                                                           urlSession: urlSession),
                  sdkLog: VCSDKLog.sharedInstance)
    }
    
    init(formatter: IssuanceResponseFormatting,
         apiCalls: IssuanceNetworking,
         discoveryApiCalls: DiscoveryNetworking,
         requestValidator: IssuanceRequestValidating,
         identifierService: IdentifierManager,
         linkedDomainService: LinkedDomainService,
         sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.formatter = formatter
        self.apiCalls = apiCalls
        self.discoveryApiCalls = discoveryApiCalls
        self.requestValidator = requestValidator
        self.identifierService = identifierService
        self.linkedDomainService = linkedDomainService
        self.sdkLog = sdkLog
    }
    
    func getRequest(usingUrl url: String) async throws -> IssuanceRequest {
        return try await logTime(name: "Issuance getRequest") {
            let signedContract = try await self.apiCalls.getRequest(withUrl: url)
            let document = try await self.getIdentifierDocument(from: signedContract)
            
            guard let publicKeys = document.verificationMethod else
            {
                throw IssuanceServiceError.noPublicKeysInIdentifierDocument
            }
            
            try self.requestValidator.validate(request: signedContract, usingKeys: publicKeys)
            let linkedDomainResult = try await self.linkedDomainService.validateLinkedDomain(from: document)
            return IssuanceRequest(from: signedContract, linkedDomainResult: linkedDomainResult)
        }
    }
    
    func send(response: IssuanceResponseContainer) async throws -> VerifiableCredential {
        return try await logTime(name: "Issuance sendResponse") {
            let signedToken = try self.formatIssuanceResponse(response: response)
            return try await self.apiCalls.sendResponse(usingUrl:  response.audienceUrl, withBody: signedToken)
        }
    }
    
    func sendCompletionResponse(for response: IssuanceCompletionResponse, to url: String) async throws {
        try await logTime(name: "Issuance sendCompletionResponse") {
            try await self.apiCalls.sendCompletionResponse(usingUrl: url, withBody: response)
        }
    }
    
    private func getIdentifierDocument(from request: SignedContract) async throws -> IdentifierDocument {
        let did = try getDIDFromHeader(request: request)
        return try await discoveryApiCalls.getDocument(from: did)
    }
    
    private func getDIDFromHeader(request: SignedContract) throws -> String {
        
        guard let kid = request.headers.keyId?.split(separator: ServicesConstants.FRAGMENT_SEPARATOR),
              let did = kid.first else {
            
            throw IssuanceServiceError.noKeyIdInRequestHeader
        }
        
        return String(did)
    }
    
    private func formatIssuanceResponse(response: IssuanceResponseContainer) throws -> IssuanceResponse {
        /// fetch or create master identifier
        let identifier = try identifierService.fetchOrCreateMasterIdentifier()
        sdkLog.logVerbose(message: "Signing Issuance Response with Identifier")
        
        return try self.formatter.format(response: response, usingIdentifier: identifier)
    }
}
