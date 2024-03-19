/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * OpenID4VCI specific Verifiable Credential object contains the raw VC, and the display information.
 */
struct SelfSignedVerifiableCredential: InternalVerifiedId
{
    public let id: String
    
    public let style: VerifiedIdStyle
    
    public let expiresOn: Date?
    
    public let issuedOn: Date
    
    let types: [String]
    
    let raw: VerifiableCredential
    
    init(raw: String) throws
    {
        guard let vc = VerifiableCredential(from: raw) else
        {
            throw MappingError.InvalidProperty(property: "rawToken", in: "raw")
        }
        
        let id = try VCClaims.getRequiredProperty(property: vc.content.jti,
                                                  propertyName: "jti")
        
        let issuedOn = try VCClaims.getRequiredProperty(property: vc.content.iat,
                                                        propertyName: "iat")
        
        self.raw = vc
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
        
        self.style = BasicVerifiedIdStyle(name: "",
                                          issuer: "",
                                          backgroundColor: "",
                                          textColor: "",
                                          description: "",
                                          logo: nil)
    }
    
    enum CodingKeys: String, CodingKey
    {
        case vc
    }
    
    public init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawToken = try values.decode(String.self, forKey: .vc)
        try self.init(raw: rawToken)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let serializedToken = try raw.serialize()
        try container.encode(serializedToken, forKey: .vc)
    }
    
    /// TODO: implement in next PR.
    public func getClaims() -> [VerifiedIdClaim]
    {
        var verifiedIdClaims: [VerifiedIdClaim] = []
        return verifiedIdClaims
    }
}
