/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class TokenValidationError: VerifiedIdError
{
    static func InvalidProperty(_ prop: String?, expected: String) -> TokenValidationError
    {
        let message = "Invalid Property \(String(describing: prop)), expected: \(expected)"
        return TokenValidationError(message: message,
                                    code: "invalid_property",
                                    correlationId: nil)
    }
    
    static func TokenHasExpired() -> TokenValidationError
    {
        let message = "Token has expired."
        return TokenValidationError(message: message,
                                    code: "token_expired",
                                    correlationId: nil)
    }
    
    static func IatHasNotOccurred() -> TokenValidationError
    {
        let message = "Token iat has not occurred."
        return TokenValidationError(message: message,
                                    code: "token_invalid",
                                    correlationId: nil)
    }
}
