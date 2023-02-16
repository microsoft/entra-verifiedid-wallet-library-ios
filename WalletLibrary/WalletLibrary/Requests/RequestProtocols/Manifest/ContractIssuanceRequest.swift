/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Issuance Request that is Contract specific.
 * TODO: we will need contract specific data to implement complete and cancel.
 * TODO: add VerifiedIdStyle property.
 */
class ContractIssuanceRequest: VerifiedIdIssuanceRequest {
    
    public let style: RequesterStyle
    
    public let requirement: Requirement
    
    public let rootOfTrust: RootOfTrust
    
    private let verifiedIdRequester: VerifiableCredentialRequester
    
    private let configuration: LibraryConfiguration
    
    private var responseContainer: IssuanceResponseContainer
    
    init(content: VerifiedIdRequestContent,
         issuanceResponseContainer: IssuanceResponseContainer,
         verifiedIdRequester: VerifiableCredentialRequester,
         configuration: LibraryConfiguration) {
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.responseContainer = issuanceResponseContainer
        self.verifiedIdRequester = verifiedIdRequester
        self.configuration = configuration
    }
    
    public func isSatisfied() -> Bool {
        /// TODO: implement.
        return false
    }
    
    public func complete() async -> Result<VerifiedId, Error> {
        do {
            try self.responseContainer.add(requirement: requirement)
            let verifiableCredential = try await verifiedIdRequester.send(request: responseContainer)
            let verifiedId: VerifiedId = try configuration.mapper.map(verifiableCredential)
            return Result.success(verifiedId)
        } catch {
            return Result.failure(error)
        }
    }
    
    public func cancel(message: String?) -> Result<Void, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    
}

