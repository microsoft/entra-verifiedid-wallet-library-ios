/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdIssuanceRequestError: Error {
    case missingRequestStateForIssuanceResultCallback
    case missingCallbackURLForIssuanceResultCallback
}

/**
 * Issuance Request that is Contract specific.
 */
class ContractIssuanceRequest: VerifiedIdIssuanceRequest {
    
    public let style: RequesterStyle
    
    public let verifiedIdStyle: VerifiedIdStyle
    
    public let requirement: Requirement
    
    public let rootOfTrust: RootOfTrust
    
    let requestState: String?
    
    let issuanceResultCallbackUrl: URL?
    
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
            try requirement.validate().get()
            return true
        } catch {
            return false
        }
    }
    
    public func complete() async -> VerifiedIdResult<VerifiedId> {
        
        let result = await VerifiedIdResult<VerifiedId>.getResult {
            try self.responseContainer.add(requirement: self.requirement)
            return try await self.verifiedIdRequester.send(request: self.responseContainer)
        }
        
        await sendResultIfCallbackAndStateExist(result: result)
        return result
    }
    
    /// Send the result back to the original requester. If call fails, fail silently, and log result.
    private func sendResultIfCallbackAndStateExist(result: VerifiedIdResult<VerifiedId>) async {
        do {
            guard let requestState = requestState,
                  let issuanceResultCallbackUrl = issuanceResultCallbackUrl else {
                return
            }
            
            var wasIssuanceSuccessful: Bool
            var errorDetails: IssuanceCompletionErrorDetails? = nil
            switch result {
            case .success(_):
                wasIssuanceSuccessful = true
            case .failure(_):
                wasIssuanceSuccessful = false
                errorDetails = .issuanceServiceError
            }
            
            let result = IssuanceCompletionResponse(wasSuccessful: wasIssuanceSuccessful,
                                                    withState: requestState,
                                                    andDetails: errorDetails)
            
            try await verifiedIdRequester.send(result: result, to: issuanceResultCallbackUrl)
        } catch {
            configuration.logger.logError(message: "Unable to send issuance result back to requester with error: \(String(describing: error))")
        }
    }
    
    /// Send the issuance result back to the original requester.
    /// TODO: Add support for injecting cancel message into callback. Right now "user canceled"
    /// will be the message sent back.
    public func cancel(message: String? = nil) async -> VerifiedIdResult<Void> {
        return await VerifiedIdResult<Void>.getResult {
            guard let requestState = self.requestState else {
                throw VerifiedIdIssuanceRequestError.missingRequestStateForIssuanceResultCallback
            }
            
            guard let issuanceResultCallbackUrl = self.issuanceResultCallbackUrl else {
                throw VerifiedIdIssuanceRequestError.missingCallbackURLForIssuanceResultCallback
            }
            
            let result = IssuanceCompletionResponse(wasSuccessful: false,
                                                    withState: requestState,
                                                    andDetails: IssuanceCompletionErrorDetails.userCanceled)
            try await self.verifiedIdRequester.send(result: result, to: issuanceResultCallbackUrl)
        }
    }
}
