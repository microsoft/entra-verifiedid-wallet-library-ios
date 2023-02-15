/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Representation of Issuer Style configured by a Manifest implemented in 2020.
 * TODO: Add more attributes from manifest.
 */
struct Manifest2020IssuerStyle: RequesterStyle, Equatable {
    var name: String
}
