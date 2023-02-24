/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/**
 * The Verified Id Data Model.
 */
public protocol VerifiedId: Codable {
    
    /// the id of the verified id. For example, this value would equal the jti of a Verifiable Credential.
    var id: String { get }
    
    /// a list of claims within the verified id.
    var claims: [VerifiedIdClaim] { mutating get }
    
    /// date the verified id expires.
    var expiresOn: Date? { get }
    
    /// date the verified id was issued.
    var issuedOn: Date { get }
}

