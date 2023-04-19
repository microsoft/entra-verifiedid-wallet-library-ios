/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A constraint on a requirement that defines a behavior of determining whether a VerifiedId
 * matches that constraint or not.
 */
protocol VerifiedIdConstraint {
    /// Returns true if Verified Id matches the constrant. Else, false.
    func doesMatch(verifiedId: VerifiedId) -> Bool
    
    /// Throws an error if constraint is not met that explains why constraint is not met.
    func matches(verifiedId: VerifiedId) throws
}
