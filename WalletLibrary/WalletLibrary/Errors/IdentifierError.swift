/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Internal implementation fo `ExtensionIdentierManager` that handles Identifier operations used within Wallet Library Extensions.
 */
class IdentifierError: VerifiedIdError
{
    static func NoKeysInDocument() -> IdentifierError
    {
        return IdentifierError(message: "No keys found in Identifier document.",
                               code: "no_keys_found_in_document")
    }
    
    static func UnableToCreateSelfSignedVerifiedId(error: Error?) -> IdentifierError
    {
        return IdentifierError(message: "Unable to create self signed Verified ID.",
                               code: "verified_id_creation_error",
                               error: error)
    }
    
    /// Optional nested error.
    let error: Error?
    
    fileprivate init(message: String,
                     code: String,
                     error: Error? = nil,
                     correlationId: String? = nil)
    {
        self.error = error
        super.init(message: message,
                   code: code,
                   correlationId: correlationId)
    }
    
    private enum CodingKeys: String, CodingKey
    {
        case message, code, correlationId, error
    }
    
    override func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(describing: error), forKey: .error)
        try super.encode(to: encoder)
    }
}
