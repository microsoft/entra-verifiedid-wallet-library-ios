/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Protocol is used as a wrapper to wrap the VC SDK get contract method.
 */
protocol ContractResolver {
    /// Fetches and validates the contract.
    func getRequest(url: String) async throws -> any RawContract
}
