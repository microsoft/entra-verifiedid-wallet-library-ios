/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Verified Id Data Model.
 */
public protocol VerifiedId: Codable {
    
    var style: VerifiedIdStyle { get }
    
    /// the id of the verified id. For example, this value would equal the jti of a Verifiable Credential.
    var id: String { get }
    
    /// date the verified id expires.
    var expiresOn: Date? { get }
    
    /// date the verified id was issued.
    var issuedOn: Date { get }
    
    func getClaims() -> [VerifiedIdClaim]
}

