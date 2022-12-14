/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum ContractTranslatorError: Error {
    case NoIdTokenScopePresent
    case NoRawValueInContract(contractUrl: String)
    case NoVerifiedIdRequirementIdPresent
}

/**
 *
 */
class ContractTranslator {
    
    init() { }
    
//    func translate(contract: VCEntities.IssuanceRequest) async throws -> Contract {
//        
//        guard let rawContract = contract.token.rawValue else {
//            throw ContractTranslatorError.NoRawValueInContract(contractUrl: contract.content.id)
//        }
//        
//        let rootOfTrust = getRootOfTrust(contract: contract)
//        let verifiedIdRequirements = try getVerifiedIdRequirements(contract: contract.content)
//        
//        return Contract(rootOfTrust: rootOfTrust,
//                        verifiedIdRequirements: <#T##[VerifiedIdRequirement]#>,
//                        idTokenRequirements: <#T##[IdTokenRequirement]#>,
//                        accessTokenRequirements: <#T##[AccessTokenRequirement]#>,
//                        selfAttestedClaimRequirements: <#T##[SelfAttestedClaimRequirement]#>,
//                        raw: rawContract)
//    }
    
    private func getRootOfTrust(contract: VCEntities.IssuanceRequest) -> RootOfTrust {
        
        switch contract.linkedDomainResult {
        case .linkedDomainMissing:
            return RootOfTrust(verified: false, source: nil)
        case .linkedDomainUnverified(let domainUrl):
            return RootOfTrust(verified: false, source: domainUrl)
        case .linkedDomainVerified(let domainUrl):
            return RootOfTrust(verified: true, source: domainUrl)
        }
    }
    
    private func getVerifiedIdRequirements(contract: VCEntities.Contract) throws -> [VerifiedIdRequirement] {
        
        guard let vpRequirements = contract.input.attestations?.presentations else {
            return []
        }
        
        let verifiedIdRequirements = try vpRequirements.map { vpRequirement in
            try translateVerifiedIdRequirement(vpRequirement: vpRequirement)
        }
        
        return verifiedIdRequirements
    }
    
    private func translateVerifiedIdRequirement(vpRequirement: PresentationDescriptor) throws -> VerifiedIdRequirement {
        
        let acceptedIssuers = vpRequirement.issuers?.compactMap { $0.iss } ?? []
        
        var issuanceParams: CredentialIssuanceParams? = nil
        if let contracts = vpRequirement.contracts {
            issuanceParams = CredentialIssuanceParams(acceptedIssuers: acceptedIssuers, credentialIssuerMetadata: contracts)
        }
        
        return VerifiedIdRequirement(encrypted: vpRequirement.encrypted ?? false,
                                     required: vpRequirement.presentationRequired ?? false,
                                     types: [vpRequirement.credentialType],
                                     acceptedIssuers: acceptedIssuers,
                                     purpose: nil,
                                     credentialIssuanceParams: issuanceParams)
    }
}
