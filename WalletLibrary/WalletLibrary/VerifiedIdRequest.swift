/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public protocol VerifiedIdRequest {
    associatedtype T
    
    var style: RequesterStyle { get }
    
    var requirement: Requirement { get }
    
    var rootOfTrust: RootOfTrust { get }
    
    func isSatisfied() -> Bool

    func complete() async -> Result<T, Error>

    func completeWithError() -> Result<T, Error>
}

public protocol VerifiedIdIssuanceRequest: VerifiedIdRequest {
    
    var style: RequesterStyle { get }
    
    var requirement: Requirement { get }
    
    var rootOfTrust: RootOfTrust { get }
    
    func isSatisfied() -> Bool

    func complete() async -> Result<VerifiedId, Error>

    func completeWithError() -> Result<Void, Error>
}

class SIOPV1IssuanceRequest: VerifiedIdRequest {
    
    let input: VerifiedIdClientInput
    
    var configuration: VerifiedIdClientConfiguration? = nil
    
    public var style: RequesterStyle = MockRequesterStyle(requester: "test")
    
    public var requirement: Requirement = MockRequirement()
    
    public var rootOfTrust: RootOfTrust = RootOfTrust(verified: true, source: "test")
    
    init(input: VerifiedIdClientInput) {
        self.input = input
    }
    
    func start(with configuration: VerifiedIdClientConfiguration) {}
    
    public func isSatisfied() -> Bool {
        do {
            try requirement.validate()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    public func complete() async -> Result<VerifiedId, Error> {
        var claim: VerifiedIdClaim = VerifiedIdClaim(id: "mockClaim", value: "mock")
        if let requirement = requirement as? MockRequirement {
            claim = VerifiedIdClaim(id: requirement.label, value: requirement.input ?? "no input")
        }
        return Result.success(VerifiedId(id: "",
                                         type: "VerifiedEmployee",
                                         claims: [claim],
                                         expiresOn: Date(),
                                         issuedOn: Date(),
                                         raw: ""))
    }
    
    public func completeWithError() -> Result<VerifiedId, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement complete with error."))
    }
}
