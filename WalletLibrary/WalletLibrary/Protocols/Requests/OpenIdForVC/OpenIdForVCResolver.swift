/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Protocol is used as a wrapper to wrap the VC SDK get presentation response method.
 */
protocol OpenIdForVCResolver {
    /// Fetches and validates the presentation request.
    func getRequest(url: String) async throws -> OpenIdRawRequest
}
