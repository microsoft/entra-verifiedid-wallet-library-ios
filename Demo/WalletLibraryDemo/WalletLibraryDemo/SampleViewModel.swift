/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import WalletLibrary
import AuthenticationServices

enum SampleViewModelError: String, Error {
    case unableToCreateInput = "Invalid Input."
    case unableToCreateRequest = "Unable to create request."
    case requestIsUndefined = "Verified Id Request is Undefined."
    case unsupportedRequirementType = "One of the requirement types is not supported."
}


class ViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    
    /// The requirements to be gathered by the user.
    @Published var requirements: [RequirementState] = []
    
    /// The input string to kick off the flow (e.g. openid request url).
    @Published var input: String = ""
    
    /// If all requirements are satisfied, complete button is enabled.
    @Published var isCompleteButtonEnabled: Bool = false
    
    /// Show a progress view when while doing internal logic.
    @Published var isProgressViewShowing: Bool = true
    
    /// if not nil, error message to be displayed.
    @Published var errorMessage: String? = nil
    
    /// If not nil, success message to be displayed.
    @Published var successMessage: String? = nil
    
    /// If not nil, show issued verified id.
    @Published var issuedVerifiedId: VerifiedId? = nil
    
    /// The Verified Id Client is used to create requests with a configuration set by the Builder.
    private let verifiedIdClient: VerifiedIdClient?
    
    /// The current issuance or presentation request that is being processed.
    private var request: (any VerifiedIdRequest)? = nil
    
    /// TODO: enable deeplinking and the rest of the requirements.
    override init() {
        do {
            let builder = VerifiedIdClientBuilder()
            verifiedIdClient = try builder.build()
        } catch {
            verifiedIdClient = nil
//            showErrorMessage(from: error)
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func testAuthService() {
        let url = URL(string: "https://myaccount.microsoft.com/")!
        let webAuthSession = ASWebAuthenticationSession(url: url,
                                                        callbackURLScheme: "walletlibrarysample",
                                                        completionHandler: { (callback:URL?, error:Error?) in
            
            print(callback)
            print(error)
        })
        
        webAuthSession.presentationContextProvider = self
        webAuthSession.prefersEphemeralWebBrowserSession = true
        webAuthSession.start()
    }
    
    func createRequest() {
        Task {
            reset()
            isProgressViewShowing = true
            do {
                let input = try createInput()
                self.request = try await verifiedIdClient?.createVerifiedIdRequest(from: input)
                
                if let request = request {
                    try configureRequirements(requirement: request.requirement)
                    isCompleteButtonEnabled = request.isSatisfied()
                } else {
                    showErrorMessage(from: SampleViewModelError.unableToCreateRequest)
                }
                
            } catch {
                showErrorMessage(from: error, additionalInfo: "Unable to create request.")
            }
            isProgressViewShowing = false
        }
    }
    
    private func configureRequirements(requirement: Requirement) throws {
        
        if let groupRequirement = requirement as? GroupRequirement {
            for req in groupRequirement.requirements {
                try configureRequirements(requirement: req)
            }
            return
        }
        
        do {
            let requirementState = try RequirementState(requirement: requirement)
            requirements.append(requirementState)
        } catch {
            throw SampleViewModelError.unsupportedRequirementType
        }
    }
    
    private func createInput() throws -> VerifiedIdRequestInput {
        
        guard let openidUrl = URL(string: input) else {
            throw SampleViewModelError.unableToCreateInput
        }
        
        return VerifiedIdRequestURL(url: openidUrl)
    }
    
    func complete() {
        switch (request) {
        case let issuanceRequest as any VerifiedIdIssuanceRequest:
            complete(issuanceRequest: issuanceRequest)
        case let presentationRequest as any VerifiedIdPresentationRequest:
            complete(presentationRequest: presentationRequest)
        default:
            showErrorMessage(from: SampleViewModelError.requestIsUndefined)
        }
    }
    
    private func complete(issuanceRequest: any VerifiedIdIssuanceRequest) {
        Task {
            let result = await issuanceRequest.complete()
            switch (result) {
            case .success(let verifiedId):
                showSuccessfulFlow(with: verifiedId)
            case .failure(let error):
                showErrorMessage(from: error)
            }
        }
    }
    
    private func complete(presentationRequest: any VerifiedIdPresentationRequest) {
        Task {
            let result = await presentationRequest.complete()
            switch (result) {
            case .success(_):
                showSuccessfulFlow()
            case .failure(let error):
                showErrorMessage(from: error)
            }
        }
    }
    
    func fulfill(requirementState: RequirementState, with value: String) throws {
        do {
            try requirementState.fulfill(with: value)
        } catch RequirementStateError.invalidInputToFulfillRequirement {
            showErrorMessage(from: RequirementStateError.invalidInputToFulfillRequirement, additionalInfo: "Value == \(value)")
        }
        self.isCompleteButtonEnabled = request?.isSatisfied() ?? false
    }
    
    private func showErrorMessage(from error: Error, additionalInfo: String? = nil) {
        print(error)
        if let error = error as? SampleViewModelError {
            errorMessage = error.rawValue
        } else if let error = error as? RequirementStateError {
            errorMessage = error.rawValue
        } else {
            errorMessage = error.localizedDescription
        }
        
        if let additionalInfo = additionalInfo {
            errorMessage?.append("\n\(additionalInfo)")
        }
    }
    
    private func showSuccessfulFlow(with verifiedId: VerifiedId? = nil) {
        
        if let verifiedId = verifiedId {
            issuedVerifiedId = verifiedId
        } else {
            successMessage = "Presentation Successful!"
        }
    }
    
    func reset() {
        errorMessage = nil
        successMessage = nil
        issuedVerifiedId = nil
        requirements = []
        request = nil
    }
}
