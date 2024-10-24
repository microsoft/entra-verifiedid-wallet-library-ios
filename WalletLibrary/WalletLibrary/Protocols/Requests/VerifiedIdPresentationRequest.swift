/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A Verified Id Presentation Request contains the look and feel of the verifier,
 * the requirement needed to fulfill the request, and the root of trust.
 */
public protocol VerifiedIdPresentationRequest: VerifiedIdRequest where T == Void 
{
    /// The nonce on the request. Nonce must be public for the Id Token Issuance Flow.
    var nonce: String? { get }
}
