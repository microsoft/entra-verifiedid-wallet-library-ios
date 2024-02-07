/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum OpenId4VCIHandlerError: Error
{
    case Unimplemented
    case InputNotSupported
    case PropertyNotPresent(String)
    case CredentialOfferGrantPropertyIsEmpty
}

/**
 * Handles a raw Open Id request and configures a VeriifedIdRequest object.
 * Post Private Preview TODO: add processors to support multiple profiles of open id.
 */
struct OpenId4VCIHandler: RequestHandling
{
    func canHandle(rawRequest: Any) -> Bool 
    {
        guard let request = rawRequest as? [String: Any],
              request["credential_issuer"] != nil else
        {
            return false
        }
        
        return true
    }
    
    func handle(rawRequest: Any) async throws -> any VerifiedIdRequest
    {
        guard let requestJson = rawRequest as? [String: Any] else
        {
            throw OpenId4VCIHandlerError.InputNotSupported
        }
        
        let credentialIssuer: String = try validateValueExists("credential_issuer", in: requestJson)
        let issuerSession: String = try validateValueExists("issuer_session", in: requestJson)
        let credentialConfigurationIds: [String] = try validateValueExists("credential_configuration_ids",
                                                                           in: requestJson)
        let rawGrants: [String: Any] = try validateValueExists("grants",
                                                               in: requestJson)
        var grants: [String: CredentialOfferGrant] = [:]
        for (key, value) in rawGrants
        {
            if let rawGrant = value as? [String: Any]
            {
                let authorizationServer: String = try validateValueExists("issuer_session",
                                                                          in: rawGrant)
                let credentialOfferGrant = CredentialOfferGrant(authorization_server: authorizationServer)
                grants[key] = credentialOfferGrant
            }
        }
        
        guard grants.isEmpty else
        {
            throw OpenId4VCIHandlerError.CredentialOfferGrantPropertyIsEmpty
        }
        
        let credentialOffer = CredentialOffer(credential_issuer: credentialIssuer,
                                              issuer_session: issuerSession,
                                              credential_configuration_ids: credentialConfigurationIds,
                                              grants: grants)
        
        throw OpenId4VCIHandlerError.Unimplemented
    }
    
    private func validateValueExists<T>(_ key: String, in json: [String: Any]) throws -> T
    {
        guard let value = json[key] as? T else
        {
            throw OpenId4VCIHandlerError.PropertyNotPresent(key)
        }
        
        return value
    }
}
