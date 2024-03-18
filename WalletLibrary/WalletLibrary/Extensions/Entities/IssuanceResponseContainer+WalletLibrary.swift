/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum IssuanceResponseContainerError: Error, Equatable {
    case unableToCastVCSDKIssuanceRequestFromRawManifestOfType(String)
    case unableToCastVerifiedIdRequestURLFromInputOfType(String)
    case unsupportedRequirementOfType(String)
    case unsupportedVerifiedIdOfType(String)
}

/**
 * An extension of the VCEntities.IssuanceResponseContainer class
 * to convert Requirements to mappings in IssuanceResponseContainer.
 */
extension IssuanceResponseContainer: IssuanceResponseContaining {
    
    struct Constants {
        static let IdTokenHintKey = "https://self-issued.me"
    }
    
    init(from manifest: any RawManifest, input: VerifiedIdRequestInput) throws {
        
        guard let manifest = manifest as? IssuanceRequest else {
            let manifestType = String(describing: type(of: manifest))
            throw IssuanceResponseContainerError.unableToCastVCSDKIssuanceRequestFromRawManifestOfType(manifestType)
        }
        
        guard let input = input as? VerifiedIdRequestURL else {
            let inputType = String(describing: type(of: input))
            throw IssuanceResponseContainerError.unableToCastVerifiedIdRequestURLFromInputOfType(inputType)
        }
        
        try self.init(from: manifest.content, contractUri: input.url.absoluteString)
    }
    
    mutating func add(requirement: Requirement) throws {
        switch (requirement) {
        case let groupRequirement as GroupRequirement:
            try add(groupRequirement: groupRequirement)
        case let idTokenRequirement as IdTokenRequirement:
            try add(idTokenRequirement: idTokenRequirement)
        case let accessTokenRequirement as AccessTokenRequirement:
            try add(accessTokenRequirement: accessTokenRequirement)
        case let verifiedIdRequirement as VerifiedIdRequirement:
            try add(verifiedIdRequirement: verifiedIdRequirement)
        case let selfAttestedClaimRequirement as SelfAttestedClaimRequirement:
            try add(selfAttestedRequirement: selfAttestedClaimRequirement)
        case let pinRequirement as PinRequirement:
            try add(pinRequirement: pinRequirement)
        default:
            let requirementType = String(describing: type(of: requirement))
            throw IssuanceResponseContainerError.unsupportedRequirementOfType(requirementType)
        }
    }
    
    private mutating func add(groupRequirement: GroupRequirement) throws {
        try groupRequirement.validate().get()
        for requirement in groupRequirement.requirements {
            try add(requirement: requirement)
        }
    }
    
    private mutating func add(idTokenRequirement: IdTokenRequirement) throws {
        try idTokenRequirement.validate().get()
        
        if idTokenRequirement.configuration.absoluteString == Constants.IdTokenHintKey {
            self.issuanceIdToken = idTokenRequirement.idToken
        } else {
            self.requestedIdTokenMap[idTokenRequirement.configuration.absoluteString] = idTokenRequirement.idToken
        }
    }
    
    private mutating func add(accessTokenRequirement: AccessTokenRequirement) throws {
        try accessTokenRequirement.validate().get()
        self.requestedAccessTokenMap[accessTokenRequirement.configuration] = accessTokenRequirement.accessToken
    }
    
    private mutating func add(verifiedIdRequirement: VerifiedIdRequirement) throws {
        
        try verifiedIdRequirement.validate().get()

        guard let vc = verifiedIdRequirement.selectedVerifiedId as? InternalVerifiedId else
        {
            let type = String(describing: type(of: verifiedIdRequirement.selectedVerifiedId))
            throw IssuanceResponseContainerError.unsupportedVerifiedIdOfType(type)
        }

        self.requestVCMap.append(RequestedVerifiableCredentialMapping(id: verifiedIdRequirement.id ?? "",
                                                                      verifiableCredential: vc.raw))
    }
    
    private mutating func add(selfAttestedRequirement: SelfAttestedClaimRequirement) throws {
        try selfAttestedRequirement.validate().get()
        self.requestedSelfAttestedClaimMap[selfAttestedRequirement.claim] = selfAttestedRequirement.value
    }
    
    private mutating func add(pinRequirement: PinRequirement) throws {
        try pinRequirement.validate().get()
        if let pin = pinRequirement.pin {
            self.issuancePin = IssuancePin(from: pin, withSalt: pinRequirement.salt)
        }
    }
}
