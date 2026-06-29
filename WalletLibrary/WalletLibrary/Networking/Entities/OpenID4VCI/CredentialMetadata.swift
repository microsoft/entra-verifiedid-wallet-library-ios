/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Credential Offer Data Model from the OpenID4VCI protocol.
 */
struct CredentialMetadata: Codable
{
    /// The end point of the credential issuer.
    let credential_issuer: String?
    
    /// The authorization servers property is a list of endpoints that can be used to get access token for this issuer.
    let authorization_servers: [String]?
    
    /// The endpoint to send response to.
    let credential_endpoint: String?
    
    /// The endpoint to send the result of the issuance back to.
    let notification_endpoint: String?
    
    /// A token to verify the issuer owns the DID and domain that the metadata comes from.
    let signed_metadata: String?
    
    /// A dictionary of Credential IDs to the corresponding credential configuration.
    let credential_configurations_supported: [String: CredentialConfiguration]?
    
    /// The display information for the issuer.
    let display: [LocalizedIssuerDisplayDefinition]?
}

/**
 * The localized display definition for the issuer.
 */
struct LocalizedIssuerDisplayDefinition: Codable
{
    /// The name of the issuer.
    let name: String?
    
    /// The locale of the display definition.
    let locale: String?
}

/**
 * Extension for the Credential Metadata.
 */
extension CredentialMetadata
{
    /// Validate the Authorization Server URL hosts specified in a credential offer are equal to the ones in the metadata.
    func validateAuthorizationServers(credentialOffer: CredentialOffer) throws
    {
        let authorizationServers = try Self.getRequiredProperty(property: authorization_servers,
                                                                propertyName: "authorization_servers")
        
        // Compare on the full normalized origin (scheme + host + port + path), not just the host.
        // A host-only comparison lets an attacker substitute an authorization server that shares the
        // host but differs in scheme/port/path, defeating the binding the offer is meant to enforce.
        let metadataAuthServerIdentifiers = authorizationServers.compactMap { URL(string: $0)?.normalizedIdentifier }
        
        for grant in credentialOffer.grants
        {
            guard let grantAuthServerIdentifier = URL(string: grant.value.authorization_server)?.normalizedIdentifier,
                  metadataAuthServerIdentifiers.contains(grantAuthServerIdentifier) else
            {
                let errorMessage = "Authorization servers in Credential Metadata does not contain \(grant.value.authorization_server)"
                throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: errorMessage)
            }
        }
    }
    
    /// Defines a function to get credentials configurations with given ids.
    func getCredentialConfigurations(ids: [String]) -> [CredentialConfiguration]
    {
        var configurations: [CredentialConfiguration] = []
        for id in ids
        {
            if let configuration = credential_configurations_supported?[id]
            {
                configurations.append(configuration)
            }
        }
        
        return configurations
    }
    
    /// Defines a function to get localized Requester Style from display definition.
    func getPreferredLocalizedIssuerDisplayDefinition() -> RequesterStyle
    {
        guard let definitions = display else
        {
            return VerifiedIdManifestIssuerStyle(name: "")
        }
        
        let preferredLanguage = Locale.preferredLanguages
        
        for definition in definitions
        {
            if let locale = definition.locale,
               preferredLanguage.contains(locale)
            {
                return VerifiedIdManifestIssuerStyle(name: definition.name ?? "")
            }
        }
        
        return VerifiedIdManifestIssuerStyle(name: definitions.first?.name ?? "")
    }
}

/**
 * Defines a typealias `SignedMetadata` that represents a JWS Token with claims specific to signed metadata.
 */
typealias SignedMetadata = JwsToken<SignedMetadataTokenClaims>

/**
 * This structure is designed to hold claims related to signed metadata tokens.
 */
struct SignedMetadataTokenClaims: Claims
{
    let sub: String?
    
    let iss: String?
    
    let exp: Int?
    
    let iat: Int?
    
    init(sub: String?, iss: String?, exp: Int? = nil, iat: Int? = nil)
    {
        self.sub = sub
        self.iss = iss
        self.exp = exp
        self.iat = iat
    }
}

/**
 * Extends `SignedMetadata` with functionality for validating the claims contained within the token.
 */
extension SignedMetadata
{
    /// Validates the claims of the signed metadata token against expected values.
    func validateClaims(expectedSubject: String,
                        expectedIssuer: String) throws
    {
        if expectedIssuer != content.iss
        {
            throw TokenValidationError.InvalidProperty("iss", actual: content.iss, expected: expectedIssuer)
        }
        
        if expectedSubject != content.sub
        {
            throw TokenValidationError.InvalidProperty("sub", actual: content.sub, expected: expectedSubject)
        }
        
        try validateIatIfPresent()
        try validateExpIfPresent()
    }
    
    /// Ensures the signed metadata token carries an expiry (`exp`) claim.
    /// A token without an expiry never expires and can be replayed indefinitely, so a missing
    /// `exp` is treated as a malformed token rather than silently accepted.
    func validateExpiryIsPresent() throws
    {
        if content.exp == nil
        {
            throw TokenValidationError.InvalidProperty("exp", actual: nil, expected: "a non-nil expiry claim")
        }
    }
}

/**
 * Helpers for comparing URLs by a normalized origin identity rather than by raw string or host alone.
 */
extension URL
{
    /// A normalized, comparable identifier for this URL: lowercased scheme and host, an explicit
    /// port (defaulting https=443 / http=80), and a path with trailing slashes trimmed.
    /// Returns nil when the scheme or host is missing (e.g. a bare, non-URL string).
    var normalizedIdentifier: String?
    {
        guard let scheme = scheme?.lowercased(),
              let host = host?.lowercased() else
        {
            return nil
        }
        
        let defaultPort: Int
        switch scheme
        {
            case "https": defaultPort = 443
            case "http": defaultPort = 80
            default: defaultPort = -1
        }
        let resolvedPort = port ?? defaultPort
        
        var normalizedPath = path
        while normalizedPath.hasSuffix("/")
        {
            normalizedPath = String(normalizedPath.dropLast())
        }
        
        return "\(scheme)://\(host):\(resolvedPort)\(normalizedPath)"
    }
    
    /// Returns true only when both strings parse to URLs that share the same normalized identifier.
    /// A non-URL string (no scheme/host) never matches, which intentionally rejects loosely formed values.
    static func haveSameIdentifier(_ lhs: String, _ rhs: String) -> Bool
    {
        guard let lhsIdentifier = URL(string: lhs)?.normalizedIdentifier,
              let rhsIdentifier = URL(string: rhs)?.normalizedIdentifier else
        {
            return false
        }
        
        return lhsIdentifier == rhsIdentifier
    }
}
