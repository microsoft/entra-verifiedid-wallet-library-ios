/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/


import PromiseKit
#if canImport(VCNetworking)
    import VCNetworking
#endif

#if canImport(VCEntities)
    import VCEntities
#endif

enum IssuanceServiceError: Error {
    case noKeyIdInRequestHeader
    case unableToCastToPresentationResponseContainer
    case unableToFetchIdentifier
}

public class IssuanceService {
    
    let formatter: IssuanceResponseFormatting
    let apiCalls: IssuanceNetworking
    let discoveryApiCalls: DiscoveryNetworking
    let requestValidator: IssuanceRequestValidating
    let identifierService: IdentifierService
    let pairwiseService: PairwiseService
    let linkedDomainService: LinkedDomainService
    let sdkLog: VCSDKLog
    
    public convenience init(correlationVector: CorrelationHeader? = nil,
                            urlSession: URLSession = URLSession.shared) {
        self.init(formatter: IssuanceResponseFormatter(),
                  apiCalls: IssuanceNetworkCalls(correlationVector: correlationVector,
                                                 urlSession: urlSession),
                  discoveryApiCalls: DIDDocumentNetworkCalls(correlationVector: correlationVector,
                                                                        urlSession: urlSession),
                  requestValidator: IssuanceRequestValidator(),
                  identifierService: IdentifierService(),
                  linkedDomainService: LinkedDomainService(correlationVector: correlationVector,
                                                           urlSession: urlSession),
                  pairwiseService: PairwiseService(correlationVector: correlationVector,
                                                   urlSession: urlSession),
                  sdkLog: VCSDKLog.sharedInstance)
    }
    
    init(formatter: IssuanceResponseFormatting,
         apiCalls: IssuanceNetworking,
         discoveryApiCalls: DiscoveryNetworking,
         requestValidator: IssuanceRequestValidating,
         identifierService: IdentifierService,
         linkedDomainService: LinkedDomainService,
         pairwiseService: PairwiseService,
         sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.formatter = formatter
        self.apiCalls = apiCalls
        self.discoveryApiCalls = discoveryApiCalls
        self.requestValidator = requestValidator
        self.identifierService = identifierService
        self.pairwiseService = pairwiseService
        self.linkedDomainService = linkedDomainService
        self.sdkLog = sdkLog
    }
    
    public func getRequest(usingUrl url: String) -> Promise<IssuanceRequest> {
        return logTime(name: "Issuance getRequest") {
            firstly {
                self.apiCalls.getRequest(withUrl: url)
            }.then { signedContract in
                self.validateRequest(signedContract)
            }.then { signedContract in
                self.formIssuanceRequest(from: signedContract)
            }
        }
    }
    
    private func formIssuanceRequest(from signedContract: SignedContract) -> Promise<IssuanceRequest> {
        
        return firstly {
            linkedDomainService.validateLinkedDomain(from: signedContract.content.input.issuer)
        }.then { linkedDomainResult in
            Promise { seal in
                seal.fulfill(IssuanceRequest(from: signedContract, linkedDomainResult: linkedDomainResult))
            }
        }
    }
    
    public func send(response: IssuanceResponseContainer, isPairwise: Bool = false) -> Promise<VerifiableCredential> {
        return logTime(name: "Issuance sendResponse") {
            firstly {
                /// turn off pairwise until we have a better solution.
                self.exchangeVCsIfPairwise(response: response, isPairwise: false)
            }.then { response in
                self.formatIssuanceResponse(response: response)
            }.then { signedToken in
                self.apiCalls.sendResponse(usingUrl:  response.audienceUrl, withBody: signedToken)
            }
        }
    }
    
    public func sendCompletionResponse(for response: IssuanceCompletionResponse, to url: String) -> Promise<String?> {
        return logTime(name: "Issuance sendCompletionResponse") {
            self.apiCalls.sendCompletionResponse(usingUrl: url, withBody: response)
        }
    }
    
    private func validateRequest(_ request: SignedContract) -> Promise<SignedContract> {
        return firstly {
            self.getDIDFromHeader(request: request)
        }.then { did in
            self.discoveryApiCalls.getDocument(from: did)
        }.then { document in
            self.wrapValidationInPromise(request: request, usingKeys: document.verificationMethod)
        }
    }
    
    private func getDIDFromHeader(request: SignedContract) -> Promise<String> {
        return Promise { seal in
            
            guard let kid = request.headers.keyId?.split(separator: ServicesConstants.FRAGMENT_SEPARATOR),
                  let did = kid.first else {
                
                seal.reject(IssuanceServiceError.noKeyIdInRequestHeader)
                return
            }
            
            seal.fulfill(String(did))
        }
    }
    
    private func wrapValidationInPromise(request: SignedContract, usingKeys keys: [IdentifierDocumentPublicKey]?) -> Promise<SignedContract> {
        
        guard let publicKeys = keys else {
            return Promise { seal in
                seal.reject(PresentationServiceError.noPublicKeysInIdentifierDocument)
            }
        }
        
        return Promise { seal in
            do {
                try self.requestValidator.validate(request: request, usingKeys: publicKeys)
                seal.fulfill(request)
            } catch {
                seal.reject(error)
            }
        }
    }
    
    private func exchangeVCsIfPairwise(response: IssuanceResponseContainer, isPairwise: Bool) -> Promise<IssuanceResponseContainer> {
        if isPairwise {
            return firstly {
                pairwiseService.createPairwiseResponse(response: response)
            }.then { response in
                self.castToIssuanceResponse(from: response)
            }
        } else {
            return Promise { seal in
                seal.fulfill(response)
            }
        }
    }
    
    private func formatIssuanceResponse(response: IssuanceResponseContainer) -> Promise<IssuanceResponse> {
        return Promise { seal in
            do {
                /// fetch or create master identifier
                let identifier = try identifierService.fetchOrCreateMasterIdentifier()
                sdkLog.logVerbose(message: "Signing Issuance Response with Identifier")
                
                seal.fulfill(try self.formatter.format(response: response, usingIdentifier: identifier))
            } catch {
                seal.reject(error)
            }
        }
    }
    
    private func castToIssuanceResponse(from response: ResponseContaining) -> Promise<IssuanceResponseContainer> {
        return Promise<IssuanceResponseContainer> { seal in
            
            guard let presentationResponse = response as? IssuanceResponseContainer else {
                seal.reject(IssuanceServiceError.unableToCastToPresentationResponseContainer)
                return
            }
            
            seal.fulfill(presentationResponse)
        }
    }
}
