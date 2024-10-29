/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class LibraryConfigurationTests: XCTestCase {
    
    func testIsPreviewFeatureSupported_WhenFeatureIsSupported_ReturnTrue() throws
    {
        // Arrange
        let mockFeatureFlag = "MockFeatureFlag"
        let previewFeatureFlag = PreviewFeatureFlags(previewFeatureFlags: [mockFeatureFlag])
        let configuration = LibraryConfiguration(previewFeatureFlags: previewFeatureFlag)
        
        // Act / Assert
        XCTAssert(configuration.isPreviewFeatureFlagSupported(mockFeatureFlag))
    }
    
    func testIsPreviewFeatureSupported_WhenFeatureDoesNotExist_ReturnFalse() throws
    {
        // Arrange
        let mockFeatureFlag = "MockFeatureFlag"
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertFalse(configuration.isPreviewFeatureFlagSupported(mockFeatureFlag))
    }
    
    func testAddIdentiferHolders_WhenInjecting2IdentifierHolders_FactoryContainsHolders() throws
    {
        // Arrange
        let _ = VerifiableCredentialSDK.initialize()
        let mockHolder1 = MockHolderIdentifier(id: "mock1")
        let mockHolder2 = MockHolderIdentifier(id: "mock2")
        
        // Act
        let configuration = LibraryConfiguration(identifiers: [mockHolder1, mockHolder2])
        
        // Assert
        XCTAssertEqual(configuration.identifierFactory.identifiers[0] as? MockHolderIdentifier, mockHolder1)
        XCTAssertEqual(configuration.identifierFactory.identifiers[1] as? MockHolderIdentifier, mockHolder2)
    }
}
