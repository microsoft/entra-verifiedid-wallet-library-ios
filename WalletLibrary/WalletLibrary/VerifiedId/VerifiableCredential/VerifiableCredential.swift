/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiableCredentialError: Error {
    case missingIssuedOnValueInVerifiableCredential
    case missingJtiInVerifiableCredential
    case unableToDecodeRawVerifiableCredentialToken
}

/**
 * Verifiable Credential object contains the raw VC, and the contract that created the Verifiable Credential.
 * This object conforms to the Mappable protocol and maps VC claims and display contract to a Verified Id.
 */
struct VCVerifiedId: InternalVerifiedId {

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
        self.issuedOn = Date(timeIntervalSince1970: TimeInterval(issuedOn))
        self.id = id
        self.types = raw.content.vc?.type ?? []
        
        if let expiresOn = raw.content.exp {
            self.expiresOn = Date(timeIntervalSince1970: TimeInterval(expiresOn))
        } else {
            self.expiresOn = nil
        }
        
        self.style = try Mapper().map(contract.display.card)
    }
    
    enum CodingKeys: String, CodingKey {
        case raw, contract
    }
    
    /// Do not change this logic. This method determines how Verified IDs will be deserialized.
    /// Developer are encouraged to use this logic to deserialize Verified IDs from their databases.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawToken = try values.decode(String.self, forKey: .raw)
        guard let raw = VerifiableCredential(from: rawToken) else {
            throw VerifiableCredentialError.unableToDecodeRawVerifiableCredentialToken
        }
        let contract = try values.decode(Contract.self, forKey: .contract)
        try self.init(raw: raw, from: contract)
    }
    
    /// Do not change this logic. This method determines how Verified IDs will be serialized.
    /// Developer are encouraged to use this logic to serialize Verified IDs from their databases.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let serializedToken = try raw.serialize()
        try container.encode(serializedToken, forKey: .raw)
        try container.encode(contract, forKey: .contract)
    }
    
    public func getClaims() -> [VerifiedIdClaim] 
    {
        
        guard let vcClaims = raw.content.vc?.credentialSubject else 
        {
            return []
        }
        
        let claimLabels = contract.display.claims
        var verifiedIdClaims: [VerifiedIdClaim] = []

        for (claim, value) in vcClaims 
        {
            if let claimStyle = claimLabels["vc.credentialSubject.\(claim)"]
            {
                verifiedIdClaims.append(VerifiedIdClaim(id: claim,
                                                        label: claimStyle.label,
                                                        type: claimStyle.type,
                                                        value: value))
            }
            else
            {
                /// Default to String.
                verifiedIdClaims.append(VerifiedIdClaim(id: claim,
                                                        label: nil,
                                                        type: nil,
                                                        value: value))
            }
        }
        
        return verifiedIdClaims
    }
}
