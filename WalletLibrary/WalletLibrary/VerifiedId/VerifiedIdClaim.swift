/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A mapping of the claims contained within a Verified Id.
 */
public struct VerifiedIdClaim
{
    /// The id of the claim
    public let id: String
    
    /// The label of the claim. This id can be used as a label to display the claims.
    public let label: String?
    
    /// The type of data object the value is.
    public let type: String?
    
    /// The value of the claim.
    public let value: Any
}
