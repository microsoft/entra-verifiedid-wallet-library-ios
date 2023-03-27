/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of encoding a Verified Id.
 */
protocol VerifiedIdEncoding {
    func encode(verifiedId: VerifiedId) throws -> Data
}
