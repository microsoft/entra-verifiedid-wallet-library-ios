/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Issuance Request that is Contract specific.
 * TODO: we will need contract specific data to implement complete and cancel.
 * TODO: add VerifiedIdStyle property.
 */
class ContractIssuanceRequest: VerifiedIdIssuanceRequest {
    
    public let style: RequesterStyle
    
    public let requirement: Requirement
    
    public let rootOfTrust: RootOfTrust
    
    private let configuration: LibraryConfiguration
    
    init(content: VerifiedIdRequestContent, configuration: LibraryConfiguration) {
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.configuration = configuration
    }
    
    public func isSatisfied() -> Bool {
        /// TODO: implement.
        return false
    }
    
    public func complete() async -> Result<VerifiedId, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    public func cancel(message: String?) -> Result<Void, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    
}

