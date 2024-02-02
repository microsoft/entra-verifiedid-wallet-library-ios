/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class LibraryConfigurationTests: XCTestCase {
    
    func testIsPreviewFeatureSupported_WhenFeatureIsSupported_ReturnTrue() async throws {
        // Arrange
        let mockFeatureFlag = "MockFeatureFlag"
        let previewFeatureFlag = PreviewFeatureFlags(previewFeatureFlags: [mockFeatureFlag])
        let configuration = LibraryConfiguration(previewFeatureFlags: previewFeatureFlag)
        
        // Act / Arrange
        XCTAssert(configuration.isPreviewFeatureFlagSupported(mockFeatureFlag))
    }
    
    func testIsPreviewFeatureSupported_WhenFeatureDoesNotExist_ReturnFalse() async throws {
        // Arrange
        let mockFeatureFlag = "MockFeatureFlag"
        let configuration = LibraryConfiguration()
        
        // Act / Arrange
        XCTAssertFalse(configuration.isPreviewFeatureFlagSupported(mockFeatureFlag))
    }
}
