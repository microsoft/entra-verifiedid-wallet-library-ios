/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum VerifiableCredentialMappingError: Error {
    case missingJtiInVerifiableCredential
}

/**
 * Verifiable Credential object contains the raw VC, and the contract that created the Verifiable Credential.
 * This object conforms to the Mappable protocol and maps VC claims and display contract to a Verified Id.
 */
struct VerifiableCredential: Mappable {
    
    let raw: VCEntities.VerifiableCredential
    
    let contract: Contract
    
    init(raw: VCEntities.VerifiableCredential, from contract: Contract) {
        self.raw = raw
        self.contract = contract
    }
    
    func map(using mapper: Mapping) throws -> VerifiedId {
        
        let rawToken = try raw.serialize()
        let id = try getRequiredProperty(property: raw.content.jti, propertyName: "jti")
        let issuedOnDate = try getRequiredProperty(property: raw.content.iat, propertyName: "issued on date")
        let expiresOnDate = try getRequiredProperty(property: raw.content.exp, propertyName: "expires on date")
        
        return VerifiedId(id: id,
                          type: VerifiedIdType.verifiableCredential,
                          claims: try createClaims(),
                          expiresOn: Date(timeIntervalSince1970: expiresOnDate),
                          issuedOn: Date(timeIntervalSince1970: issuedOnDate),
                          raw: rawToken)
    }
    
    private func createClaims() throws -> [VerifiedIdClaim] {
        let vcClaims = try getRequiredProperty(property: raw.content.vc?.credentialSubject, propertyName: "claims")
        let claimLabels = contract.display.claims
        
        var verifiedIdClaims: [VerifiedIdClaim] = []
        /// TODO: add casting to correct type from contract.
        for (claim, value) in vcClaims {
            if let claimStyle = claimLabels["vc.credentialSubject.\(claim)"] {
                verifiedIdClaims.append(VerifiedIdClaim(id: claimStyle.label,
                                                        value: value))
            } else {
                verifiedIdClaims.append(VerifiedIdClaim(id: claim,
                                                        value: value))
            }
        }
        
        return verifiedIdClaims
    }
}
