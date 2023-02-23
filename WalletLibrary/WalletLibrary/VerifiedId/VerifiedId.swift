/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/**
 * The Verified Id Data Model.
 */
public struct VerifiedId {
    
    /// the id of the verified id. For example, this value would equal the jti of a Verifiable Credential.
    public let id: String
    
    /// the type of the verified id. For example, Verifiable Credential would be the type of a VC.
    public let type: VerifiedIdType
    
    /// a list of claims within the verified id.
    public let claims: [VerifiedIdClaim]
    
    /// date the verified id expires.
    public let expiresOn: Date
    
    /// date the verified id was issued.
    public let issuedOn: Date
    
    /// the raw representation of the verified id.
    let raw: String
}

