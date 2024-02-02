/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw Response from the Issuance Service that issues Wallet a Verified ID.
 */
struct CredentialConfiguration: Decodable
{
    /// The Verified ID issued.
    let format: String?
    
    /// The notification id to pass to notification endpoint.
    let scope: String?
    
    /// The crypto binding methods supported (ex. did:jwk)
    let cryptographic_binding_methods_supported: [String]?
    
    /// The crypto suites supported (ex. ES256)
    let cryptographic_suites_supported: [String]?
    
    /// Describes the metadata of the supported credential.
    let credential_definition: CredentialDefinition?
}

/**
 * Describes the metadata of the supported credential.
 */
struct CredentialDefinition: Decodable
{
    /// The types of the credential.
    let type: [String]?
    
    /// A mapping to describe how to display the claims in the credential.
    let credentialSubject: [String: CredentialSubjectDefinition]?
    
    /// The type of proof that can be used to show ownership of keys bound to crypto binding method (ex. jwt).
    let proof_types_supported: [String]?
    
    /// Describes the way to display the credential.
    let display: [LocalizedDisplayDefinition]?
}

/**
 * Describes the way to display the credential.
 */
struct CredentialSubjectDefinition: Decodable
{
    /// An array of ways to display the credential with different locales.
    let display: [LocalizedDisplayDefinition]
}

/**
 * Describes the way to display the credential based on a specific locale..
 */
struct LocalizedDisplayDefinition: Decodable
{
    /// The name of the credential in specific locale.
    let name: String?
    
    /// The locale of the display definition.
    let locale: String?
    
    /// Describes the logo metadata for the credential.
    let logo: LogoDisplayDefinition?
    
    /// The background color of the credential.
    let background_color: String?
    
    /// The text color of the credential.
    let text_color: String?
}

/**
 * Describes the logo metadata for the credential.
 */
struct LogoDisplayDefinition: Decodable
{
    /// Data uri of the logo.
    let uri: String?
    
    /// Alt Text that describes the logo.
    let alt_text: String?
}
