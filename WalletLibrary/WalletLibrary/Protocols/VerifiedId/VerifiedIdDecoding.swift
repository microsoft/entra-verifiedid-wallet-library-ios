/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of decoding a Verified Id.
 */
protocol VerifiedIdDecoding {
    func decode(from data: Data) throws -> any VerifiedId
}
