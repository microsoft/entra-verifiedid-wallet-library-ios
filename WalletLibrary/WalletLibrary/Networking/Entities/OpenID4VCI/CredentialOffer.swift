/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Credential Offer Data Model from the OpenID4VCI protocol.
 */
struct CredentialOffer: Codable
{
    /// The end point of the credential issuer metadata.
    let credential_issuer: String
    
    /// The state of the request. Opaque to the wallet.
    let issuer_session: String
    
    /// The credential ids that will be used to issue the Verified ID.
    let credential_configuration_ids: [String]
    
    /// An object indicating to the Wallet the Grant Types the Credential Issuer's AS is prepared to process for this Credential Offer.
    let grants: [String: CredentialOfferGrant]
    
    enum CodingKeys: String, CodingKey
    {
        case credential_issuer = "credential_issuer"
        case issuer_session
        case credential_configuration_ids
        case grants
    }
}

struct CredentialOfferGrant: Codable
{
    /**
     * A string that the Wallet can use to identify the Authorization Server to use with this grant type
     * when authorization_servers parameter in the Credential Issuer metadata has multiple entries.
     * MUST NOT be used otherwise.
     * The value of this parameter MUST match with one of the values in the authorization_servers array obtained from the Credential Issuer metadata.
     */
    let authorization_server: String
    
    let pre_authorized_code: String?
    
    let tx_code: CredentialOfferGrantCode?
    
    enum CodingKeys: String, CodingKey
    {
        case pre_authorized_code = "pre-authorized_code"
        case authorization_server
        case tx_code
    }
    
    init(authorization_server: String, 
         pre_authorized_code: String? = nil,
         tx_code: CredentialOfferGrantCode? = nil) {
        self.authorization_server = authorization_server
        self.pre_authorized_code = pre_authorized_code
        self.tx_code = tx_code
    }
}

struct CredentialOfferGrantCode: Codable, MappableTarget
{
    let length: Int
    
    let input_mode: String
    
    enum CodingKeys: String, CodingKey
    {
        case length
        case input_mode
    }
    
    static func map(_ object: Dictionary<String, Any>, using mapper: Mapping) throws -> CredentialOfferGrantCode
    {
        let length: Int = try validateValueExists(CodingKeys.length.rawValue,
                                                  in: object)
        
        let input_mode: String = try validateValueExists(CodingKeys.input_mode.rawValue,
                                                         in: object)
        
        return CredentialOfferGrantCode(length: length, input_mode: input_mode)
    }
}

extension CredentialOffer: MappableTarget
{
    static func map(_ object: Dictionary<String, Any>, using mapper: Mapping) throws -> Self
    {
        let credentialIssuer: String = try validateValueExists(CodingKeys.credential_issuer.rawValue,
                                                               in: object)
        let issuerSession: String = try validateValueExists(CodingKeys.issuer_session.rawValue, in: object)
        let credentialConfigurationIds: [String] = try validateValueExists(CodingKeys.credential_configuration_ids.rawValue,
                                                                           in: object)
        let rawGrants: [String: Any] = try validateValueExists(CodingKeys.grants.rawValue,
                                                               in: object)
        var grants: [String: CredentialOfferGrant] = [:]
        for (key, value) in rawGrants
        {
            if let rawGrant = value as? [String: Any]
            {
                grants[key] = try mapper.map(rawGrant, type: CredentialOfferGrant.self)
            }
        }
        
        guard !grants.isEmpty else
        {
            throw MappingError.PropertyNotPresent(property: CodingKeys.grants.rawValue,
                                                  in: String(describing: Self.self))
        }
        
        return CredentialOffer(credential_issuer: credentialIssuer,
                               issuer_session: issuerSession,
                               credential_configuration_ids: credentialConfigurationIds,
                               grants: grants)
    }
}

extension CredentialOfferGrant: MappableTarget
{
    static func map(_ object: Dictionary<String, Any>, using mapper: Mapping) throws -> CredentialOfferGrant
    {
        let authorizationServer: String = try validateValueExists(CodingKeys.authorization_server.rawValue,
                                                                  in: object)
        
        let preAuthCode: String? = object[CodingKeys.pre_authorized_code.rawValue] as? String
        
        var code: CredentialOfferGrantCode? = nil
        if let txCode = object[CodingKeys.tx_code.rawValue] as? Dictionary<String, Any>
        {
            code = try mapper.map(txCode,
                                  type: CredentialOfferGrantCode.self)
        }
        
        return CredentialOfferGrant(authorization_server: authorizationServer, 
                                    pre_authorized_code: preAuthCode,
                                    tx_code: code)
    }
}
