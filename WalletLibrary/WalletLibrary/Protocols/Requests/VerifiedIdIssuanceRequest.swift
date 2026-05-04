/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A Verified Id Issuance Request contains the look and feel of the issuer and verified id,
 * the requirement needed to fulfill the request, and the root of trust.
 */
public protocol VerifiedIdIssuanceRequest: VerifiedIdRequest where T == VerifiedId {
    
    /// The look and feel of the Verified Id.
    var verifiedIdStyle: VerifiedIdStyle { get }
    
    var scenario: String? { get }
    
    var continuation: ContinuationDescriptor? { get }

    /// The credential issuer endpoint URL.
    var credentialIssuer: String? { get }

    /// The credential endpoint URL. Will be `nil` for the manifest flow.
    var credentialEndpoint: String? { get }
}

public extension VerifiedIdIssuanceRequest {
    var credentialIssuer: String? { nil }
    var credentialEndpoint: String? { nil }
}
