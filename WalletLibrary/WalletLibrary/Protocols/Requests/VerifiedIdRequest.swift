/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol that handles a Verified Id Request that contains the look and feel of the requester,
 * the requirement needed to fulfill request, and the root of trust.
 */
public protocol VerifiedIdRequest {
    associatedtype Style
    associatedtype Response
    
    /// The look and feel of the requester.
    var style: Style { get }
    
    /// The requirement needed to fulfill request.
    var requirement: Requirement { get }
    
    /// The root of trust results between the request and the source of the request.
    var rootOfTrust: RootOfTrust { get }
    
    /// Whether or not the request is satisfied on client side.
    func isSatisfied() -> Bool

    /// Completes the request and returns a generic object if successful.
    func complete() async -> Result<Response, Error>

    /// Cancel the request with an optional message.
    func cancel(message: String?) -> Result<Void, Error>
}

/**
 * Protocol that represents an Issuance Request.
 * TODO: add VerifiedId Style
 */
public protocol VerifiedIdIssuanceRequest: VerifiedIdRequest where Style: IssuerStyle, Response == VerifiedId  {
    
    var verifiedIdStyle: VerifiedIdStyle { get }
}

/**
 * Protocol that represents a Presentation Request.
 */
public protocol VerifiedIdPresentationRequest: VerifiedIdRequest where Style: VerifierStyle, Response == Void { }
