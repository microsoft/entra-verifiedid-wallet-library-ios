/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A protocol to describe the behavior of iterating over properties in an object/struct.
 * The purpose is to easily convert an object into a Form URLEncoded String for networking Post requests.
 */
protocol PropertyIterable: Encodable
{
    func allProperties() -> [String: String?]
}
