/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Protocol is used as a wrapper to wrap the VC SDK get contract method.
 */
protocol ManifestResolver {
    /// Fetches and validates the contract.
    func resolve(with url: String) async throws -> any RawManifest
}
