/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

enum VerifiedIdIssuanceRequestError: Error {
    case missingRequestStateForIssuanceResultCallback
    case missingCallbackURLForIssuanceResultCallback
}

/**
 * Issuance Request that is Contract specific.
 * TODO: add VerifiedIdStyle property.
 */
class ContractIssuanceRequest: VerifiedIdIssuanceRequest {
    
    public let style: RequesterStyle
    
    public let verifiedIdStyle: VerifiedIdStyle
    
    public let requirement: Requirement
    
    public let rootOfTrust: RootOfTrust
    
    private let requestState: String?
    
    private let issuanceResultCallbackUrl: URL?
    
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
        self.requestState = content.requestState
        self.issuanceResultCallbackUrl = content.issuanceResultCallbackUrl
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
            
            /// Only call the issuance result callback if state and callback url exist.
            if let requestState = requestState,
               let issuanceResultCallbackUrl = issuanceResultCallbackUrl {
                await sendSuccessfulResult(state: requestState, callbackUrl: issuanceResultCallbackUrl)
            }
            
            return Result.success(verifiedId)
        } catch {
            return Result.failure(error)
        }
    }
    
    /// Send the result back to the original requester. If call fails, fail silently, and log result.
    private func sendSuccessfulResult(state: String, callbackUrl: URL) async {
        do {
            let result = IssuanceCompletionResponse(wasSuccessful: true, withState: state)
            try await verifiedIdRequester.send(result: result, to: callbackUrl)
        } catch {
            configuration.logger.logError(message: "Unable to send issuance result back to requester with error: \(String(describing: error))")
        }
    }
    
    /// Send the issuance result back to the original requester.
    /// TODO: Add support for injecting cancel message into callback. Right now "user canceled"
    /// will be the message sent back.
    public func cancel(message: String?) async -> Result<Void, Error> {
        do {
            
            guard let requestState = requestState else {
                throw VerifiedIdIssuanceRequestError.missingRequestStateForIssuanceResultCallback
            }
            
            guard let issuanceResultCallbackUrl = issuanceResultCallbackUrl else {
                throw VerifiedIdIssuanceRequestError.missingCallbackURLForIssuanceResultCallback
            }
            
            let result = IssuanceCompletionResponse(wasSuccessful: false,
                                                    withState: requestState,
                                                    andDetails: IssuanceCompletionErrorDetails.userCanceled)
            try await verifiedIdRequester.send(result: result, to: issuanceResultCallbackUrl)
            return Result.success(())
        } catch {
            return Result.failure(error)
        }
    }
    
    
}

