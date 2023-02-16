/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.IssuanceRequest class.
 * TODO: Update RawContract to RawManifest
 */
extension VCEntities.IssuanceResponseContainer {
    
    init(from rawContract: any RawContract, input: VerifiedIdRequestInput) throws {
        
        guard let contract = rawContract as? IssuanceRequest else {
            throw VerifiedIdClientError.TODO(message: "implement")
        }
        
        guard let input = input as? VerifiedIdRequestURL else {
            throw VerifiedIdClientError.TODO(message: "implement")
        }
        
        try self.init(from: contract.content, contractUri: input.url.absoluteString)
    }
    
    mutating func add(requirement: Requirement) throws {
        switch (requirement) {
        case is GroupRequirement:
            try add(groupRequirement: requirement as! GroupRequirement)
        case is IdTokenRequirement:
            try add(idTokenRequirement: requirement as! IdTokenRequirement)
        case is AccessTokenRequirement:
            try add(accessTokenRequirement: requirement as! AccessTokenRequirement)
        case is VerifiedIdRequirement:
            try add(verifiedIdRequirement: requirement as! VerifiedIdRequirement)
        case is SelfAttestedClaimRequirement:
            try add(selfAttestedRequirement: requirement as! SelfAttestedClaimRequirement)
        case is PinRequirement:
            try add(pinRequirement: requirement as! PinRequirement)
        default:
            throw VerifiedIdClientError.TODO(message: "implement")
        }
    }
    
    private mutating func add(groupRequirement: GroupRequirement) throws {
        try groupRequirement.validate()
        for requirement in groupRequirement.requirements {
            try add(requirement: requirement)
        }
    }
    
    private mutating func add(idTokenRequirement: IdTokenRequirement) throws {
        try idTokenRequirement.validate()
        self.requestedIdTokenMap[idTokenRequirement.configuration.absoluteString] = idTokenRequirement.idToken
    }
    
    private mutating func add(accessTokenRequirement: AccessTokenRequirement) throws {
        try accessTokenRequirement.validate()
        self.requestedAccessTokenMap[accessTokenRequirement.configuration] = accessTokenRequirement.accessToken
    }
    
    private mutating func add(verifiedIdRequirement: VerifiedIdRequirement) throws {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
    
    private mutating func add(selfAttestedRequirement: SelfAttestedClaimRequirement) throws {
        try selfAttestedRequirement.validate()
        self.requestedSelfAttestedClaimMap[selfAttestedRequirement.claim] = selfAttestedRequirement.value
    }
    
    private mutating func add(pinRequirement: PinRequirement) throws {
        try pinRequirement.validate()
        if let pin = pinRequirement.pin {
            self.issuancePin = IssuancePin(from: pin, withSalt: pinRequirement.salt)
        }
    }
}
