/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockManifestResolver: ManifestResolver {
    
    let mockGetRequestCallback: ((String) throws -> any RawManifest)?
    
    init(mockGetRequestCallback: ((String) throws -> any RawManifest)? = nil) {
        self.mockGetRequestCallback = mockGetRequestCallback
    }
    
    func resolve(with url: URL) async throws -> any RawManifest {
        return try mockGetRequestCallback?(url.absoluteString) ?? MockRawManifest(id: "")
    }
}
