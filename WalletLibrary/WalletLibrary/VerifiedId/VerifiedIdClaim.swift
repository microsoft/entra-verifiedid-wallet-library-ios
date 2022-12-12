/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A mapping of the claims contained within a Verified Id.
 */
public struct VerifiedIdClaim {
    /// id of the claim. For example, within a VC, it is the key value of credentialSubject.
    let id: String
    
    /// the value of the claim.
    let value: Any
}

