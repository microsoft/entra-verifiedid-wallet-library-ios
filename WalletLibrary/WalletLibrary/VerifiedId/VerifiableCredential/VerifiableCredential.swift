/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum VerifiableCredentialMappingError: Error {
    case missingJtiInVerifiableCredential
    case unableToDecodeRawVerifiableCredentialToken
    case missingIssuedOnValueInVerifiableCredential
}

/**
 * Verifiable Credential object contains the raw VC, and the contract that created the Verifiable Credential.
 * This object conforms to the Mappable protocol and maps VC claims and display contract to a Verified Id.
 */
struct VerifiableCredential: VerifiedId {

    public let id: String
    
    public let expiresOn: Date?
    
    public let issuedOn: Date
    
    let raw: VCEntities.VerifiableCredential
    
    let contract: Contract
    
    init(raw: VCEntities.VerifiableCredential, from contract: Contract) throws {
        
        guard let issuedOn = raw.content.iat else {
            throw VerifiableCredentialMappingError.missingIssuedOnValueInVerifiableCredential
        }
        
        guard let id = raw.content.jti else {
            throw VerifiableCredentialMappingError.missingJtiInVerifiableCredential
        }
        
        self.raw = raw
        self.contract = contract
        self.issuedOn = Date(timeIntervalSince1970: issuedOn)
        self.id = id
        
        if let expiresOn = raw.content.exp {
            self.expiresOn = Date(timeIntervalSince1970: expiresOn)
        } else {
            self.expiresOn = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case raw, contract
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawToken = try values.decode(String.self, forKey: .raw)
        guard let raw = VCEntities.VerifiableCredential(from: rawToken) else {
            throw VerifiableCredentialMappingError.unableToDecodeRawVerifiableCredentialToken
        }
        let contract = try values.decode(Contract.self, forKey: .contract)
        try self.init(raw: raw, from: contract)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let serializedToken = try raw.serialize()
        try container.encode(serializedToken, forKey: .raw)
        try container.encode(contract, forKey: .contract)
    }
    
    public func getClaims() -> [VerifiedIdClaim] {
        return createClaims()
    }
    
    private func createClaims() -> [VerifiedIdClaim] {
        
        guard let vcClaims = raw.content.vc?.credentialSubject else {
            return []
        }
        
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
