/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class CredentialMetadataTests: XCTestCase
{
    private let mapper = Mapper()
    
    func testGetPreferredLocalizedIssuerDisplayDefinition_WhenConfigValuesAreNil_ReturnStyle() async throws
    {
        // Arrange
        let metadata = createCredentialMetadata(issuerName: "expectedIssuerName")
        
        // Act
        let result = metadata.getPreferredLocalizedIssuerDisplayDefinition()
        
        // Assert
        XCTAssert(result is VerifiedIdManifestIssuerStyle)
        XCTAssertEqual(result.name, "expectedIssuerName")
    }
    
    func testGetLocalizedVerifiedIdStyle_WhenConfigValuesAreNil_ReturnVerifiedIdStyle() async throws
    {
        // Arrange
        let emptyConfig = CredentialConfiguration(format: nil,
                                                  scope: nil,
                                                  cryptographic_binding_methods_supported: nil,
                                                  cryptographic_suites_supported: nil,
                                                  credential_definition: nil,
                                                  display: nil, 
                                                  proof_types_supported: nil)
        
        // Act
        let result = emptyConfig.getLocalizedVerifiedIdStyle(withIssuerName: "issuerName")
        
        // Assert
        XCTAssert(result is BasicVerifiedIdStyle)
        let basicVerifiedIdStyle = result as! BasicVerifiedIdStyle
        XCTAssertEqual(basicVerifiedIdStyle.issuer, "issuerName")
        XCTAssertNil(basicVerifiedIdStyle.logo)
        XCTAssert(basicVerifiedIdStyle.backgroundColor.isEmpty)
        XCTAssert(basicVerifiedIdStyle.description.isEmpty)
        XCTAssert(basicVerifiedIdStyle.name.isEmpty)
        XCTAssert(basicVerifiedIdStyle.textColor.isEmpty)
    }
    
    func testGetLocalizedVerifiedIdStyle_WithConfigValues_ReturnVerifiedIdStyle() async throws
    {
        // Arrange
        let displayDefinition = LocalizedDisplayDefinition(name: "expectedName",
                                                           locale: "",
                                                           logo: nil,
                                                           description: "expectedDescription",
                                                           background_color: "expectedBackground",
                                                           text_color: "expectedTextColor")
        let definition = CredentialDefinition(type: nil,
                                              credential_subject: nil)
        let emptyConfig = CredentialConfiguration(format: nil,
                                                  scope: nil,
                                                  cryptographic_binding_methods_supported: nil,
                                                  cryptographic_suites_supported: nil,
                                                  credential_definition: definition,
                                                  display: [displayDefinition],
                                                  proof_types_supported: nil)
        
        // Act
        let result = emptyConfig.getLocalizedVerifiedIdStyle(withIssuerName: "issuerName")
        
        // Assert
        XCTAssert(result is BasicVerifiedIdStyle)
        let basicVerifiedIdStyle = result as! BasicVerifiedIdStyle
        XCTAssertEqual(basicVerifiedIdStyle.issuer, "issuerName")
        XCTAssertNil(basicVerifiedIdStyle.logo)
        XCTAssertEqual(basicVerifiedIdStyle.backgroundColor, "expectedBackground")
        XCTAssertEqual(basicVerifiedIdStyle.description, "expectedDescription")
        XCTAssertEqual(basicVerifiedIdStyle.name, "expectedName")
        XCTAssertEqual(basicVerifiedIdStyle.textColor, "expectedTextColor")
    }
    
    func testGetLocalizedVerifiedIdStyle_With2Definitions_ReturnVerifiedIdStyle() async throws
    {
        // Arrange
        let preferredLocale = Locale.preferredLanguages.first
        let displayDefinition1 = LocalizedDisplayDefinition(name: "expectedName",
                                                           locale: preferredLocale,
                                                           logo: nil,
                                                           description: "expectedDescription",
                                                           background_color: "expectedBackground",
                                                           text_color: "expectedTextColor")
        
        let displayDefinition2 = LocalizedDisplayDefinition(name: "unsupportedName",
                                                            locale: "unsupportedLocale",
                                                            logo: nil,
                                                            description: "unsupportedDescription",
                                                            background_color: "unsupportedBackground",
                                                            text_color: "unsupportedextColor")
        let definition = CredentialDefinition(type: nil,
                                              credential_subject: nil)
        let emptyConfig = CredentialConfiguration(format: nil,
                                                  scope: nil,
                                                  cryptographic_binding_methods_supported: nil,
                                                  cryptographic_suites_supported: nil,
                                                  credential_definition: definition,
                                                  display: [displayDefinition1, displayDefinition2],
                                                  proof_types_supported: nil)
        
        // Act
        let result = emptyConfig.getLocalizedVerifiedIdStyle(withIssuerName: "issuerName")
        
        // Assert
        XCTAssert(result is BasicVerifiedIdStyle)
        let basicVerifiedIdStyle = result as! BasicVerifiedIdStyle
        XCTAssertEqual(basicVerifiedIdStyle.issuer, "issuerName")
        XCTAssertNil(basicVerifiedIdStyle.logo)
        XCTAssertEqual(basicVerifiedIdStyle.backgroundColor, "expectedBackground")
        XCTAssertEqual(basicVerifiedIdStyle.description, "expectedDescription")
        XCTAssertEqual(basicVerifiedIdStyle.name, "expectedName")
        XCTAssertEqual(basicVerifiedIdStyle.textColor, "expectedTextColor")
    }
    
    private func createCredentialMetadata(expectedConfigs: [String: CredentialConfiguration] = [:],
                                          issuerName: String = "issuerName") -> CredentialMetadata
    {
        let metadata = CredentialMetadata(credential_issuer: "credentialIssuer",
                                          authorization_servers: ["expectedAuthorizationServer"],
                                          credential_endpoint: nil,
                                          notification_endpoint: nil,
                                          signed_metadata: "eymockToken",
                                          credential_configurations_supported: expectedConfigs,
                                          display: [LocalizedIssuerDisplayDefinition(name: issuerName, locale: nil)])
        return metadata
    }
}
