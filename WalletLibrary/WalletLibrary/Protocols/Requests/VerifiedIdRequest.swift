/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A Verified Id Request contains the look and feel of the requester,
 * the requirement needed to fulfill the request, the root of trust.
 *
 * The Request also defines the behavior of completing or canceling the request
 * and checking whether the requirement on the request is satisfied.
 */
public protocol VerifiedIdRequest {
    associatedtype T
    
    /// The look and feel of the requester.
    var style: RequesterStyle { get }
    
    /// The requirement needed to fulfill request.
    var requirement: Requirement { get }
    
    /// The root of trust results between the request and the source of the request.
    var rootOfTrust: RootOfTrust { get }
    
    /// Whether or not the request is satisfied on client side.
    func isSatisfied() -> Bool

    /// Completes the request and returns a generic object if successful.
    func complete() async -> VerifiedIdResult<T>

    /// Cancel the request with an optional message.
    func cancel(message: String?) async -> VerifiedIdResult<Void>
}
