/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Verifiable Credential object contains the raw VC, and the contract that created the Verifiable Credential.
 * This object conforms to the Mappable protocol and maps VC claims and display contract to a Verified Id.
 */
struct OpenID4VCIVerifiedId: VerifiedId 
{
    public let id: String
    
    public let style: VerifiedIdStyle
    
    public let expiresOn: Date?
    
    public let issuedOn: Date
    
    let types: [String]
    
    let vc: VerifiableCredential
    
    let metadata: CredentialMetadata
    
    init(raw: String, metadata: CredentialMetadata) throws
    {
        guard let vc = VerifiableCredential(from: raw) else
        {
            throw MappingError.InvalidProperty(property: "rawToken", in: "raw")
        }
        
        let issuedOn = try VCClaims.getRequiredProperty(property: vc.content.iat,
                                                        propertyName: "iat")
        let id = try VCClaims.getRequiredProperty(property: vc.content.jti,
                                                  propertyName: "jti")
        
        self.vc = vc
        self.metadata = metadata
        self.issuedOn = Date(timeIntervalSince1970: issuedOn)
        self.id = id
        self.types = vc.content.vc?.type ?? []
        
        if let expiresOn = vc.content.exp
        {
            self.expiresOn = Date(timeIntervalSince1970: expiresOn)
        } 
        else
        {
            self.expiresOn = nil
        }
        
        self.style = BasicVerifiedIdStyle(name: "", issuer: "", backgroundColor: "", textColor: "", description: "", logo: nil)
    }
    
    enum CodingKeys: String, CodingKey 
    {
        case vc, metadata
    }
    
    public init(from decoder: Decoder) throws 
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawToken = try values.decode(String.self, forKey: .vc)
        
        guard let raw = VerifiableCredential(from: rawToken) else 
        {
            throw VerifiableCredentialError.unableToDecodeRawVerifiableCredentialToken
        }
        
        let metadata = try values.decode(CredentialMetadata.self, forKey: .metadata)
        try self.init(raw: rawToken, metadata: metadata)
    }
    
    public func encode(to encoder: Encoder) throws 
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let serializedToken = try vc.serialize()
        try container.encode(serializedToken, forKey: .vc)
        try container.encode(metadata, forKey: .metadata)
    }
    
    public func getClaims() -> [VerifiedIdClaim] 
    {
        guard let vcClaims = vc.content.vc?.credentialSubject else
        {
            return []
        }
        
//        let claimLabels = contract.display.claims
        
        var verifiedIdClaims: [VerifiedIdClaim] = []
        /// TODO: add casting to correct type from contract.
//        for (claim, value) in vcClaims {
//            if let claimStyle = claimLabels["vc.credentialSubject.\(claim)"] {
//                verifiedIdClaims.append(VerifiedIdClaim(id: claimStyle.label,
//                                                        value: value))
//            } else {
//                verifiedIdClaims.append(VerifiedIdClaim(id: claim,
//                                                        value: value))
//            }
//        }
        
        return verifiedIdClaims
    }
}
