/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

/**
 * Contents of an OpenID Self-Issued Token Request.
 *
 * @see [OpenID Spec](https://openid.net/specs/openid-connect-core-1_0.html#JWTRequests)
 */
protocol OIDCClaims: Claims {
    var audience: String? { get }
    var responseType: String? { get }
    var responseMode: String? { get }
    var clientID: String? { get }
    var redirectURI: String? { get }
    var scope: String? { get }
    var state: String? { get }
    var nonce: String? { get }
    var issuer: String? { get }
    var registration: RegistrationClaims? { get }
    var prompt: String? { get }
    var claims: RequestedClaims? { get }
}

extension OIDCClaims {
    var audience: String? {
        return nil
    }
    
    var responseType: String? {
        return nil
    }
    
    var responseMode: String? {
        return nil
    }
    
    var clientID: String? {
        return nil
    }
    
    var redirectURI: String? {
        return nil
    }
    
    var scope: String? {
        return nil
    }

    var state: String? {
        return nil
    }
    
    var nonce: String? {
        return nil
    }
    
    var issuer: String? {
        return nil
    }
    
    var registration: RegistrationClaims? {
        return nil
    }
    
    var prompt: String? {
        return nil
    }
    
    var claims: RequestedClaims? {
        return nil
    }
}
