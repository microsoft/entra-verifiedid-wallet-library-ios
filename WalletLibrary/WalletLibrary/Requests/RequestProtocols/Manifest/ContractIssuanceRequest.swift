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
    
    private let contractResponder: ContractResponder
    
    private let configuration: LibraryConfiguration
    
    private let rawContract: any RawContract
    
    private let input: VerifiedIdRequestInput
    
    init(content: VerifiedIdRequestContent,
         rawContract: any RawContract,
         input: VerifiedIdRequestInput,
         contractResponder: ContractResponder,
         configuration: LibraryConfiguration) {
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.rawContract = rawContract
        self.input = input
        self.contractResponder = contractResponder
        self.configuration = configuration
    }
    
    public func isSatisfied() -> Bool {
        /// TODO: implement.
        return false
    }
    
    public func complete() async -> Result<VerifiedId, Error> {
        do {
            var responseContainer = try IssuanceResponseContainer(from: rawContract, input: input)
            try responseContainer.add(requirement: requirement)
            let rawVerifiedId = try await contractResponder.send(requestContent: responseContainer)
            return Result.success(VerifiedId(id: "test",
                                             type: "type",
                                             claims: [],
                                             expiresOn: Date(),
                                             issuedOn: Date(),
                                             raw: rawVerifiedId.raw))
        } catch {
            return Result.failure(error)
        }
    }
    
    public func cancel(message: String?) -> Result<Void, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    
}

