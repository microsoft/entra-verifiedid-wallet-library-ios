/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utilities such as logger, mapper, httpclient (post private preview) that are configured in builder and
 * all of library will use.
 */
extension JwsToken
{
    struct TokenHeaderKeyId
    {
        let did: String
        
        let keyId: String
    }
    
    func getKeyId() -> TokenHeaderKeyId?
    {
        guard let components = headers.keyId?.split(separator: "#",
                                                    maxSplits: 1,
                                                    omittingEmptySubsequences: true) else
        {
            return nil
        }
        
        return TokenHeaderKeyId(did: String(components[0]),
                                keyId: String(components[1]))
    }
    
    func validateIatAndExp() throws
    {
        guard let exp = content.exp else
        {
            throw TokenValidationError.PropertyNotPresent("exp")
        }
        
        guard let iat = content.iat else
        {
            throw TokenValidationError.PropertyNotPresent("iat")
        }
        
        guard getCurrentTimeInSecondsWithDelay() > exp else
        {
            throw TokenValidationError.TokenHasExpired
        }
        
        guard getCurrentTimeInSecondsWithDelay() < iat else
        {
            throw TokenValidationError.IatHasNotOccurred
        }
    }
    
    private func getCurrentTimeInSecondsWithDelay() -> Double {
        let currentTimeInSeconds = (Date().timeIntervalSince1970).rounded(.down)
        return currentTimeInSeconds - Double(300)
    }
}

