/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/


import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

enum PairwiseServiceError: Error {
    case noSubjectInVerifiableCredentialToExchange
}

class PairwiseService {
    
    private let exchangeService: ExchangeService
    private let identifierService: IdentifierService
    
    convenience init(correlationVector: CorrelationHeader? = nil,
                     urlSession: URLSession = URLSession.shared) {
        self.init(exchangeService: ExchangeService(correlationVector: correlationVector,
                                                   urlSession: urlSession),
                  identifierService: IdentifierService())
    }
    
    init(exchangeService: ExchangeService,
         identifierService: IdentifierService) {
        self.exchangeService = exchangeService
        self.identifierService = identifierService
    }
    
    func createPairwiseResponse(response: ResponseContaining) -> Promise<ResponseContaining> {
        var res = response
        return firstly {
            self.createPairwiseIdentifier(forId: VCEntitiesConstants.MASTER_ID, andRelyingParty: response.audienceDid)
        }.then { pairwiseIdentifier in
            self.exchangeRequestedVcs(vcs: response.requestVCMap, newOwnerDid: pairwiseIdentifier.longFormDid)
        }.then { vcMap in
            self.replaceResponseVcMap(response: &res, vcMap: vcMap)
        }
    }
    
    private func createPairwiseIdentifier(forId id: String, andRelyingParty rp: String) -> Promise<Identifier> {
        return Promise { seal in
            seal.fulfill(try identifierService.createAndSaveIdentifier(forId: id, andRelyingParty: rp))
        }
    }
    
    private func exchangeRequestedVcs(vcs: RequestedVerifiableCredentialMap, newOwnerDid: String) -> Promise<[RequestedVerifiableCredentialMapping]> {
        var promises: [Promise<RequestedVerifiableCredentialMapping>] = []
        for vc in vcs {
            promises.append(exchangeVerifiableCredential(type: vc.inputDescriptorId, exchangeableVerifiableCredential: vc.vc, newOwnerDid: newOwnerDid))
        }
        return when(fulfilled: promises)
    }
    
    private func exchangeVerifiableCredential(type: String, exchangeableVerifiableCredential vc: VerifiableCredential, newOwnerDid: String) -> Promise<RequestedVerifiableCredentialMapping> {
        
        do {
            let ownerIdentifier = try getOwnerIdentifier(forVc: vc)
            let exchangeRequest = try ExchangeRequestContainer(
                exchangeableVerifiableCredential: vc,
                newOwnerDid: newOwnerDid,
                currentOwnerIdentifier: ownerIdentifier)
            
            return firstly {
                self.exchangeService.send(request: exchangeRequest)
            }.then { vc in
                self.combineVCAndType(type: type, vc: vc)
            }
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
    
    private func combineVCAndType(type: String, vc: VerifiableCredential) -> Promise<RequestedVerifiableCredentialMapping> {
        return Promise { seal in
            seal.fulfill(RequestedVerifiableCredentialMapping(id: type, verifiableCredential: vc))
        }
    }
    
    private func replaceResponseVcMap(response: inout ResponseContaining, vcMap: [RequestedVerifiableCredentialMapping]) -> Promise<ResponseContaining> {
        response.requestVCMap = vcMap
        return Promise { seal in
            seal.fulfill(response)
        }
    }
    
    private func getOwnerIdentifier(forVc vc: VerifiableCredential) throws -> Identifier {
        
        guard let ownerLongformDid = vc.content.sub else {
            throw PairwiseServiceError.noSubjectInVerifiableCredentialToExchange
        }
        
        let nullableOwnerIdentifier = try identifierService.fetchIdentifer(withLongformDid: ownerLongformDid)
        
        guard let ownerIdentifier = nullableOwnerIdentifier else {
            throw PresentationServiceError.inputStringNotUri
        }
        
        return ownerIdentifier
    }
}
