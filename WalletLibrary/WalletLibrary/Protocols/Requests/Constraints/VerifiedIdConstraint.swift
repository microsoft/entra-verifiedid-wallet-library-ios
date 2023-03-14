/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A constraint on a requirement that defines a behavior of determining whether a VerifiedId
 * matches that constraint or not.
 * TODO: add method that throws an error to get more information about why constraint was not met.
 */
protocol VerifiedIdConstraint {
    func doesMatch(verifiedId: VerifiedId) -> Bool
}
