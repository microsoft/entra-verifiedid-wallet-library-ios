/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that describes a raw presentation response and defines the behavior of adding a requirement to it.
 * For example, a VCSDK.PresentationResponseContainer conforms to this protocol.
 */
protocol PresentationResponse {
    mutating func add(requirement: Requirement) throws
}
