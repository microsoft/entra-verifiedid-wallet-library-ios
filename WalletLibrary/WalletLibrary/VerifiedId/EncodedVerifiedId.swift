/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The data model of encoded Verified Id.
 */
struct EncodedVerifiedId: Codable {
    /// The specific type of the Verified Id (e.g. VerifiableCredential).
    let type: String

    /// The raw representation of the Verified Id.
    let raw: Data
}
