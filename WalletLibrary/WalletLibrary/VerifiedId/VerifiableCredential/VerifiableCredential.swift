/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

enum VerifiableCredentialError: Error {
    case missingIssuedOnValueInVerifiableCredential
    case missingJtiInVerifiableCredential
    case unableToDecodeRawVerifiableCredentialToken
}

/**
 * Verifiable Credential object contains the raw VC, and the contract that created the Verifiable Credential.
 * This object conforms to the Mappable protocol and maps VC claims and display contract to a Verified Id.
 */
struct VCVerifiedId: VerifiedId {
    
    public let id: String
    
    public let style: VerifiedIdStyle
    
    public let expiresOn: Date?
    
    public let issuedOn: Date
    
    let types: [String]
    
    let raw: VerifiableCredential
    
    let contract: Contract
    
    init(raw: VerifiableCredential, from contract: Contract) throws {
        
        guard let issuedOn = raw.content.iat else {
            throw VerifiableCredentialError.missingIssuedOnValueInVerifiableCredential
        }
        
        guard let id = raw.content.jti else {
            throw VerifiableCredentialError.missingJtiInVerifiableCredential
        }
        
        self.raw = raw
        self.contract = contract
        self.issuedOn = Date(timeIntervalSince1970: issuedOn)
        self.id = id
        self.types = raw.content.vc?.type ?? []
        
        if let expiresOn = raw.content.exp {
            self.expiresOn = Date(timeIntervalSince1970: expiresOn)
        } else {
            self.expiresOn = nil
        }
        
        self.style = BasicVerifiedIdStyle(name: "",
                                          issuer: "",
                                          backgroundColor: "",
                                          textColor: "",
                                          description: "",
                                          logoUrl: nil,
                                          logoAltText: nil)
    }
    
    enum CodingKeys: String, CodingKey {
        case raw, contract
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawToken = try values.decode(String.self, forKey: .raw)
        guard let raw = VerifiableCredential(from: rawToken) else {
            throw VerifiableCredentialError.unableToDecodeRawVerifiableCredentialToken
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
