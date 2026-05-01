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
    ///
    /// For legacy manifest issuance, this may also be the endpoint where the issuance response
    /// is sent. For OpenID4VCI, prefer `credentialEndpoint` as the credential request POST target.
    var credentialIssuer: String? { get }

    /// The credential endpoint URL where the credential request/token is POSTed.
    ///
    /// This is available for OpenID4VCI issuance. It may be `nil` for legacy manifest issuance.
    var credentialEndpoint: String? { get }
}

/// Default implementations preserve backward compatibility for existing protocol implementors.
public extension VerifiedIdIssuanceRequest {
    var credentialIssuer: String? { nil }
    var credentialEndpoint: String? { nil }
}
