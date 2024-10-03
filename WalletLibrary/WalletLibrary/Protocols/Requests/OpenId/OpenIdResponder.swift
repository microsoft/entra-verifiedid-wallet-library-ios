/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol is used as a wrapper to wrap the VC SDK send presentation response method.
 */
protocol OpenIdResponder {
    /// Sends the presentation response and if successful, returns void,
    /// If unsuccessful, throws an error.
    func send(response: RawPresentationResponse) async throws -> Void
}
