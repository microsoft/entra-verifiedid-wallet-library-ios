/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationResponseError: Error {
    case noAudienceInRequest
    case noAudienceDidInRequest
    case noNonceInRequest
    case noVerifiablePresentationRequestsInRequest
    case noPresentationDefinitionInVerifiablePresentationRequest
    case noInputDescriptorMatchesGivenId
}

struct PresentationResponseContainer: ResponseContaining {
    
    let request: PresentationRequest?
    
    let expiryInSeconds: Int
    
    let audienceUrl: String
    
    let audienceDid: String
    
    let nonce: String
    
    var requestedIdTokenMap: RequestedIdTokenMap = [:]
    
    var requestedSelfAttestedClaimMap: RequestedSelfAttestedClaimMap = [:]
    
    var requestVCMap: RequestedVerifiableCredentialMap = [:]
    
    init(from presentationRequest: PresentationRequest, expiryInSeconds exp: Int = 3000) throws {
        
        guard let audience = presentationRequest.content.redirectURI else {
            throw PresentationResponseError.noAudienceInRequest
        }
        
        guard let audienceDid = presentationRequest.content.clientID else {
            throw PresentationResponseError.noAudienceDidInRequest
        }
        
        guard let nonce = presentationRequest.content.nonce else {
            throw PresentationResponseError.noNonceInRequest
        }

        self.audienceUrl = audience
        self.audienceDid = audienceDid
        self.nonce = nonce
        self.request = presentationRequest
        self.expiryInSeconds = exp
    }
    
    init(audienceUrl: String,
         audienceDid: String,
         nonce: String,
         expiryInSeconds: Int) {
        self.audienceDid = audienceDid
        self.audienceUrl = audienceUrl
        self.expiryInSeconds = expiryInSeconds
        self.nonce = nonce
        self.request = nil
    }
    
    mutating func addVerifiableCredential(id: String, vc: VerifiableCredential) throws {
        
        guard let vpTokenRequest = request?.content.claims?.vpToken,
              !vpTokenRequests else {
            throw PresentationResponseError.noVerifiablePresentationRequestsInRequest
        }
        
        guard let presentationDefinition = vpTokenRequest.presentationDefinition,
                let presentationDefinitionId = presentationDefinition.id else {
            throw PresentationResponseError.noPresentationDefinitionInVerifiablePresentationRequest
        }
        
        if let inputDescriptors = presentationDefinition.inputDescriptors,
            inputDescriptors.contains(where: { $0.id == id }) {
            
            let mapping = RequestedVerifiableCredentialMapping(id: id, verifiableCredential: vc)
            
            var mappings = requestVCMap[presentationDefinitionId] ?? []
            mappings.append(mapping)
            
            requestVCMap.updateValue(mappings, forKey: presentationDefinitionId)
            return
        }
        
        throw PresentationResponseError.noInputDescriptorMatchesGivenId
    }
}
