/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A mapping of the claims contained within a Verified Id.
 */
public struct VerifiedIdClaim {
    
    /// id of the claim. This id can be used as a label to display the claims.
    public let id: String
    
    /// the value of the claim.
    public let value: Any
}
