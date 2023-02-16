/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol is used as a wrapper to wrap the VC SDK send response method.
 */
protocol ContractResponder {
    /// Fetches and validates the contract.
    func send(requestContent: RawRequestContent) async throws -> RawVerifiedId
}
