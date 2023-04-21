/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationResponseError: Error {
    case noAudienceInRequest
    case noAudienceDidInRequest
    case noNonceInRequest
}

struct PresentationResponseContainer: ResponseContaining {
    
    let request: PresentationRequest?
    
    let expiryInSeconds: Int
    
    let audienceUrl: String
    
    let audienceDid: String
    
    let nonce: String
    
    let presentationDefinitionId: String?
    
    var requestedIdTokenMap: RequestedIdTokenMap = [:]
    
    var requestedSelfAttestedClaimMap: RequestedSelfAttestedClaimMap = [:]
    
    var requestVCMap: RequestedVerifiableCredentialMap = []
    
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
        self.presentationDefinitionId = presentationRequest.content.claims?.vpToken?.presentationDefinition?.id
        self.request = presentationRequest
        self.expiryInSeconds = exp
    }
    
    init(audienceUrl: String,
                audienceDid: String,
                nonce: String,
                expiryInSeconds: Int,
                presentationDefinitionId: String)
    {
        self.audienceDid = audienceDid
        self.audienceUrl = audienceUrl
        self.expiryInSeconds = expiryInSeconds
        self.nonce = nonce
        self.presentationDefinitionId = presentationDefinitionId
        self.request = nil
    }
}
