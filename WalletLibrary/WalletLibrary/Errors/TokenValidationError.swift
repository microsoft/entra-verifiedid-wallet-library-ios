/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * This class is used to represent different types of validation errors related to tokens.
 * TODO: add a way to inject correlatin vector in all errors.
 */
class TokenValidationError: VerifiedIdError
{
    /// Creates an instance of `TokenValidationError` when property of the token does not have the expected value.
    static func InvalidProperty(_ prop: String, actual: String?, expected: String) -> TokenValidationError
    {
        if let actual = actual
        {
            let message = "Invalid String for property: \(prop). Expected: \(expected), Actual: \(actual)."
            return TokenValidationError(message: message,
                                        code: "invalid_property",
                                        correlationId: nil)
        }
        
        let message = "Propery \(prop) is not present. Expected: \(expected)."
        return TokenValidationError(message: message,
                                    code: "invalid_property",
                                    correlationId: nil)
    }
    
    /// Creates an instance of `TokenValidationError` indicating that the token has expired.
    static func TokenHasExpired() -> TokenValidationError
    {
        let message = "Token has expired."
        return TokenValidationError(message: message,
                                    code: "token_expired",
                                    correlationId: nil)
    }
    
    /// Creates an instance of `TokenValidationError` indicating that the "issued at" time (`iat`) of the token is in the future,
    /// which means the token is not yet valid.
    static func IatHasNotOccurred() -> TokenValidationError
    {
        let message = "Token iat has not occurred."
        return TokenValidationError(message: message,
                                    code: "token_invalid",
                                    correlationId: nil)
    }
    
    /// Creates an instance of `TokenValidationError` when signature is invalid.
    static func InvalidSignature() -> TokenValidationError
    {
        let message = "Signature is not valid."
        return TokenValidationError(message: message,
                                    code: "token_invalid",
                                    correlationId: nil)
    }
}
