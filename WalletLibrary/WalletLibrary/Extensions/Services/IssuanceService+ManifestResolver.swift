/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCServices)
    import VCServices
#endif

/**
 * An extension of the VCServices.IssuanceService class
 * that wraps getRequest method with a resolve method that conforms to ManifestResolver protocol.
 */
extension IssuanceService: ManifestResolver {
    
    /// Fetches and validates the manifest.
    func resolve(with url: URL) async throws -> any RawManifest {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url.absoluteString)
        }()
    }
}
