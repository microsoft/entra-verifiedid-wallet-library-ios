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
    
    public let verifiedIdStyle: VerifiedIdStyle
    
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
        self.verifiedIdStyle = content.verifiedIdStyle
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
            let result = IssuanceCompletionResponse(wasSuccessful: true, withState: "TODO")
            await send(successfulResult: result)
            return Result.success(verifiedId)
        } catch {
            return Result.failure(error)
        }
    }
    
    /// Send the result back to the original requester. If call fails, fail silently, and log result.
    private func send(successfulResult: IssuanceCompletionResponse) async {
        do {
            try await verifiedIdRequester.send(result: successfulResult, to: URL(string: "TBD")!)
        } catch {
            configuration.logger.logError(message: "Unable to send issuance result back to requester with error: \(String(describing: error))")
        }
    }
    
    public func cancel(message: String?) async -> Result<Void, Error> {
        do {
            var errorDetails: IssuanceCompletionErrorDetails = .unspecifiedError
            if let message = message,
               let details = IssuanceCompletionErrorDetails(rawValue: message) {
                errorDetails = details
            }
            
            let result = IssuanceCompletionResponse(wasSuccessful: false, withState: "TODO", andDetails: errorDetails)
            try await verifiedIdRequester.send(result: result, to: URL(string: "TBD")!)
            return Result.success(())
        } catch {
            return Result.failure(error)
        }
    }
    
    
}

