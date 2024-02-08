/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Extension for handling JSON Web Token operations.
 */
extension JwsToken
{
    /// Represents the DID (Decentralized Identifier) and Key ID extracted from the token header's key identifier.
    struct TokenHeaderKeyId
    {
        let did: String
        
        let keyId: String
    }
    
    /// Extracts and separates the DID and Key ID from the token header's key identifier.
    /// - Returns: A `TokenHeaderKeyId` containing the DID and Key ID if the extraction is successful; otherwise, `nil`.
    func getKeyId() -> TokenHeaderKeyId?
    {
        guard let components = headers.keyId?.split(separator: "#",
                                                    maxSplits: 1,
                                                    omittingEmptySubsequences: true),
              components.count == 2 else
        {
            return nil
        }
        
        return TokenHeaderKeyId(did: String(components[0]),
                                keyId: String(components[1]))
    }
    
    /// Validates the `iat` (Issued At) and `exp` (Expiration Time) claims of the token.
    func validateIatAndExp() throws
    {
        let exp = try T.getRequiredProperty(property: content.exp, propertyName: "exp")
        let iat = try T.getRequiredProperty(property: content.iat, propertyName: "iat")
        
        // Adjusts for a 5-minute (300 seconds) delay.
        guard getCurrentTimeInSeconds(delay: Double(-300)) <= exp else
        {
            throw TokenValidationError.TokenHasExpired()
        }
        
        // Adjusts for a 5-minute (300 seconds) skew.
        guard getCurrentTimeInSeconds(delay: Double(300)) >= iat else
        {
            throw TokenValidationError.IatHasNotOccurred()
        }
    }
    
    private func getCurrentTimeInSeconds(delay: Double) -> Double 
    {
        let currentTimeInSeconds = (Date().timeIntervalSince1970).rounded(.down)
        return currentTimeInSeconds + delay
    }
}

