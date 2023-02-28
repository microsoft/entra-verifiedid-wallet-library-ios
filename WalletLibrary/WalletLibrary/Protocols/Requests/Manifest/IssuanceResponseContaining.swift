/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol defines the behavior of collecting requirements to send to requester.
 * For example, it is used as a wrapper to wrap the VC SDK issuance response container.
 */
protocol IssuanceResponseContaining {
    mutating func add(requirement: Requirement) throws
}
