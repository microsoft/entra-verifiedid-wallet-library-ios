/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * OpenID4VCI specific Verifiable Credential object contains the raw VC, and the display information.
 */
struct OpenID4VCIVerifiedId: InternalVerifiedId
{
    public let id: String
    
    public let style: VerifiedIdStyle
    
    public let expiresOn: Date?
    
    public let issuedOn: Date
    
    let types: [String]
    
    let raw: VerifiableCredential
    
    let configuration: CredentialConfiguration
    
    let issuerName: String
    
    init(raw: String, 
         issuerName: String,
         configuration: CredentialConfiguration) throws
    {
        guard let vc = VerifiableCredential(from: raw) else
        {
            throw MappingError.InvalidProperty(property: "rawToken", in: "raw")
        }
        
        let issuedOn = try VCClaims.getRequiredProperty(property: vc.content.iat,
                                                        propertyName: "iat")
        let id = try VCClaims.getRequiredProperty(property: vc.content.jti,
                                                  propertyName: "jti")
        
        self.raw = vc
        self.configuration = configuration
        self.issuedOn = Date(timeIntervalSince1970: TimeInterval(issuedOn))
        self.id = id
        self.types = vc.content.vc?.type ?? []
        self.issuerName = issuerName
        
        if let expiresOn = vc.content.exp
        {
            self.expiresOn = Date(timeIntervalSince1970: TimeInterval(expiresOn))
        }
        else
        {
            self.expiresOn = nil
        }
        
        self.style = configuration.getLocalizedVerifiedIdStyle(withIssuerName: issuerName)
    }
    
    enum CodingKeys: String, CodingKey 
    {
        case vc, configuration, issuerName
    }
    
    /// Do not change this logic. This method determines how Verified IDs will be deserialized.
    /// Developer are encouraged to use this logic to deserialize Verified IDs from their databases.
    public init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawToken = try values.decode(String.self, forKey: .vc)
        let issuerName = try values.decode(String.self, forKey: .issuerName)
        let configuration = try values.decode(CredentialConfiguration.self, forKey: .configuration)
        try self.init(raw: rawToken, issuerName: issuerName, configuration: configuration)
    }
    
    /// Do not change this logic. This method determines how Verified IDs will be serialized.
    /// Developer are encouraged to use this logic to serialize Verified IDs from their databases.
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let serializedToken = try raw.serialize()
        try container.encode(serializedToken, forKey: .vc)
        try container.encode(configuration, forKey: .configuration)
        try container.encode(issuerName, forKey: .issuerName)
    }
    
    public func getClaims() -> [VerifiedIdClaim]
    {
        guard let claims = raw.content.vc?.credentialSubject else
        {
            return []
        }
        
        var verifiedIdClaims: [VerifiedIdClaim] = []
        for (claimReference, claimValue) in claims
        {
            let verifiedIdClaim = createVerifiedIdClaim(claimReference: claimReference,
                                                        claimValue: claimValue)
            verifiedIdClaims.append(verifiedIdClaim)
        }
        
        return verifiedIdClaims
    }
    
    private func createVerifiedIdClaim(claimReference: String, claimValue: Any) -> VerifiedIdClaim
    {
        guard let claimDefinitions = configuration.credential_definition?.credential_subject,
           let claimDisplayDefinitions = claimDefinitions["vc.credentialSubject.\(claimReference)"] else
        {
            return VerifiedIdClaim(id: claimReference,
                                   label: nil,
                                   type: nil,
                                   value: claimValue)
        }
        
        if let localizedDefinition = claimDisplayDefinitions.getPreferredLocalizedDisplayDefinition(),
           let label = localizedDefinition.name
        {
            return VerifiedIdClaim(id: claimReference,
                                   label: label,
                                   type: claimDisplayDefinitions.value_type,
                                   value: claimValue)
            
        }
        else
        {
            return VerifiedIdClaim(id: claimReference,
                                   label: nil,
                                   type: claimDisplayDefinitions.value_type,
                                   value: claimValue)
        }
    }
}
