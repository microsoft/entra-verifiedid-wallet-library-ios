/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public enum VerifiedIdClientError: Error {
    case notImplemented
}

public protocol VerifiedIdClient {
    associatedtype T

    var style: RequesterStyle { get }

    var requirement: Requirement { get }

    var rootOfTrust: RootOfTrust { get }
    
    func areAllRequirementsFulfilled() -> Bool

    func complete() async -> Result<T, Error>

    func completeWithError() -> Result<T, Error>
}

public class VerifiedIdIssuanceClient: VerifiedIdClient {
    
    public var style: RequesterStyle
    
    public var verfiedIdStyle: VerifiedIdStyle
    
    public var requirement: Requirement
    
    public var rootOfTrust: RootOfTrust
    
    init?(builder: VerifiedIdClientBuilder) {
        
        /// TODO: maybe this should throw an error instead.
        guard let resolvedInput = builder.resolvedInput as? MockResolvedInput else {
            return nil
        }
        
        self.style = resolvedInput.style
        self.verfiedIdStyle = resolvedInput.verifiedIdStyle
        self.requirement = resolvedInput.requirement
        self.rootOfTrust = resolvedInput.rootOfTrust
    }
    
    public func areAllRequirementsFulfilled() -> Bool {
        return true
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
        return Result.failure(VerifiedIdClientError.notImplemented)
    }
}
