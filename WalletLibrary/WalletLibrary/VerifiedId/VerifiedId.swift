/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Verified Id Data Model.
 */
public protocol VerifiedId: Codable {
    
    /// The look and feel of the Verified Id that can be used to display the Verified Id.
    var style: VerifiedIdStyle { get }
    
    /// The id of the verified id. For example, this value would equal the jti of a Verifiable Credential.
    var id: String { get }
    
    /// The date the Verified id expires.
    var expiresOn: Date? { get }
    
    /// The date the Verified Id was issued.
    var issuedOn: Date { get }
    
    /// Get the claims contained within the Verified Id that includes an id of the claim that can be used as a label.
    func getClaims() -> [VerifiedIdClaim]
}

