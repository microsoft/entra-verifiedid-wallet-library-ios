/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 * Issuance Request that is Contract specific.
 * TODO: add VerifiedIdStyle property.
 */
class ContractIssuanceRequest: VerifiedIdIssuanceRequest {
    
    public let style: RequesterStyle
    
    public let requirement: Requirement
    
    public let rootOfTrust: RootOfTrust
    
    private let verifiedIdRequester: VerifiedIdRequester
    
    private let configuration: LibraryConfiguration
    
    private var responseContainer: IssuanceResponseContaining
    
    init(content: IssuanceRequestContent,
         issuanceResponseContainer: IssuanceResponseContaining,
         verifiedIdRequester: VerifiedIdRequester,
         configuration: LibraryConfiguration) {
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.responseContainer = issuanceResponseContainer
        self.verifiedIdRequester = verifiedIdRequester
        self.configuration = configuration
    }
    
    public func isSatisfied() -> Bool {
        do {
            try requirement.validate()
            return true
        } catch {
            return false
        }
    }
    
    public func complete() async -> Result<VerifiedId, Error> {
        do {
            try self.responseContainer.add(requirement: requirement)
            let verifiedId = try await verifiedIdRequester.send(request: responseContainer)
            return Result.success(verifiedId)
        } catch {
            return Result.failure(error)
        }
    }
    
    public func cancel(message: String?) -> Result<Void, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    
}

