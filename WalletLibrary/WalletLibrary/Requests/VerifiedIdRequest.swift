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

public class VerifiedIdIssuanceRequest: VerifiedIdRequest {
    
    public var style: RequesterStyle
    
    public var requirement: Requirement
    
    public var rootOfTrust: RootOfTrust
    
    init(style: RequesterStyle, requirement: Requirement, rootOfTrust: RootOfTrust) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
    }
    
    public func isSatisfied() -> Bool {
        return false
    }
    
    public func complete() async -> Result<VerifiedId, Error> {
        let verifiedId = VerifiedId(id: "",
                                    type: "test",
                                    claims: [],
                                    expiresOn: Date(),
                                    issuedOn: Date(),
                                    raw: "test")
        return Result.success(verifiedId)
    }
    
    public func cancel(message: String?) -> Result<Void, Error> {
        return Result.success(Void())
    }
}

public struct MockRequesterStyle: RequesterStyle {
    public var requester: String = "request test"
}
