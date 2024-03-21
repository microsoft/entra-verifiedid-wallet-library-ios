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
                                keyId: "#\(String(components[1]))")
    }
    
    func validateIatIfPresent(withClockSkew skew: Int = 300) throws
    {
        if let iat = content.iat,
           getCurrentTimeInSeconds(skew: skew) <= iat
        {
                throw TokenValidationError.IatHasNotOccurred()
        }
    }
    
    func validateExpIfPresent(withClockSkew skew: Int = 300) throws
    {
        if let exp = content.exp,
           getCurrentTimeInSeconds(skew: -300) >= exp
        {
            throw TokenValidationError.TokenHasExpired()
        }
    }
    
    private func getCurrentTimeInSeconds(skew: Int) -> Int
    {
        let currentTimeInSeconds = Int((Date().timeIntervalSince1970).rounded(.down))
        return currentTimeInSeconds + skew
    }
}

