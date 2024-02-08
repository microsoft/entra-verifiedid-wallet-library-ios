/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * This class is used to represent different types of validation errors related to the OpenId4VCI Protocol.
 * TODO: add a way to inject correlatin vector in all errors.
 */
class OpenId4VCIProtocolValidationError: VerifiedIdError
{
    /// Creates an instance of `OpenId4VCIProtocolValidationError` when credential offer is malformed.
    static func MalformedCredentialOffer(message: String) -> OpenId4VCIProtocolValidationError
    {
        return OpenId4VCIProtocolValidationError(message: message,
                                                 code: "credential_metadata_malformed",
                                                 correlationId: nil)
    }
    
    /// Creates an instance of `OpenId4VCIProtocolValidationError` when encountering error with signed metadata.
    static func MalformedSignedMetadataToken(message: String,
                                             error: Error? = nil) -> OpenId4VCIProtocolValidationError
    {
        return OpenId4VCIProtocolValidationError(message: message,
                                                 code: "signed_metadata_token_malformed",
                                                 error: error,
                                                 correlationId: nil)
    }
    
    /// Creates an instance of `OpenId4VCIProtocolValidationError` when credential metadata is malformed.
    static func MalformedCredentialMetadata(message: String,
                                            error: Error? = nil) -> OpenId4VCIProtocolValidationError
    {
        return OpenId4VCIProtocolValidationError(message: message,
                                                 code: "credential_metadata_malformed",
                                                 error: error,
                                                 correlationId: nil)
    }
    
    /// Optional nested error.
    private let error: Error?
    
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

