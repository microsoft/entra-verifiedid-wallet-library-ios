/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * This class is used to represent different types of errors related to the Presentation Exchange Protocol.
 */
class PresentationExchangeError: VerifiedIdError
{
    
    /// Creates an instance of `PresentationExchangeError` when missing required property.
    static func MissingRequiredProperty(message: String,
                                        error: Error? = nil) -> PresentationExchangeError
    {
        return PresentationExchangeError(message: message,
                                         code: "missing_required_property",
                                         error: error,
                                         correlationId: nil)
    }
    
    /// Optional nested error.
    let error: Error?
    
    fileprivate init(message: String, code: String, error: Error? = nil, correlationId: String?)
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


