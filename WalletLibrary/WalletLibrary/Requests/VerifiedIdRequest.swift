/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol that handles a Verified Id Request that contains the look and feel of the requester,
 * the requirement needed to fulfill request, and the root of trust.
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
    func complete() async -> Result<T, Error>

    /// Cancel the request with an optional message.
    func cancel(message: String?) -> Result<Void, Error>
}
