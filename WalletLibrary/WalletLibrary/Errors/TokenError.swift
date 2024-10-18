/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * This class is used to represent different types of errors related to the token layer of the Wallet Library.
 */
class TokenError: VerifiedIdError 
{
    /// Creates an instance of `TokenError` indicating that unable to parse message..
    static func UnableToParseToken(component: String) -> TokenError
    {
        let message = "Unable to parse token component: \(component)."
        return TokenError(message: message,
                          code: "token_parsing_error",
                          correlationId: nil)
    }
}
