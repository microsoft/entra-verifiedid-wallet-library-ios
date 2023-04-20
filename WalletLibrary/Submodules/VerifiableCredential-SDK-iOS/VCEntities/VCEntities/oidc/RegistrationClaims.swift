/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of the Registration Property in an OpenID Self-Issued Token Request.
 *
 * @see [OpenID Spec](https://openid.net/specs/openid-connect-registration-1_0.html)
 */
public struct RegistrationClaims: Codable, Equatable {
    
    /// The name of the requester.
    public let clientName: String?
    
    /// The purpose of the request.
    public let clientPurpose: String?
    
    /// Optional logo uri of the requester.
    public let logoURI: String?
    
    /// The identifier types supported to use to respond to request (ex. did).
    public let subjectIdentifierTypesSupported: [String]?
    
    /// The supported Verfiable Presentation Formats and Algorithms to respond to request.
    public let vpFormats: SupportedVerifiablePresentationFormats?
    
    public init(clientName: String?,
                clientPurpose: String?,
                logoURI: String?,
                subjectIdentifierTypesSupported: [String]?,
                vpFormats: SupportedVerifiablePresentationFormats?) {
        self.clientName = clientName
        self.clientPurpose = clientPurpose
        self.logoURI = logoURI
        self.subjectIdentifierTypesSupported = subjectIdentifierTypesSupported
        self.vpFormats = vpFormats
    }

    enum CodingKeys: String, CodingKey {
        case clientName = "client_name"
        case clientPurpose = "client_purpose"
        case logoURI = "logo_uri"
        case subjectIdentifierTypesSupported = "subject_syntax_types_supported"
        case vpFormats = "vp_formats"
    }
}
