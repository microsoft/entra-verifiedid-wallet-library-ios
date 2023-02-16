/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCServices

/**
 * An extension of the VCServices.IssuanceService class.
 */
extension IssuanceService: ManifestResolver {
    
    /// Fetches and validates the manifest.
    func resolve(with url: URL) async throws -> any RawManifest {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url.absoluteString)
        }()
    }
}