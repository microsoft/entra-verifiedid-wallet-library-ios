/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Internal Protocol that represents an Issuance Request.
 */
public protocol VerifiedIdIssuanceRequest: VerifiedIdRequest where T == VerifiedId {
    
    var verifiedIdStyle: VerifiedIdStyle { get }
}
