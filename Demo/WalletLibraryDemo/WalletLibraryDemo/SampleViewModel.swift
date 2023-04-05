/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import WalletLibrary

enum SampleViewModelError: String, Error {
    case unableToCreateInput = "Invalid Input."
    case unableToCreateRequest = "Unable to create request."
    case requestIsUndefined = "Verified Id Request is Undefined."
    case unsupportedRequirementType = "One of the requirement types is not supported."
    case verifiedIdClientHasNotBeenInitialized = "Verified Id Client has not been initialized."
}

/// State to keep track of what state the request is in.
enum RequestState {
    case Initialized
    case CreatingRequest
    case GatheringRequirements
    case IssuanceSuccess(with: VerifiedId)
    case PresentationSuccess(with: String)
    case Error(withMessage: String)
}


@MainActor class SampleViewModel: ObservableObject {
    
    /// The state of the request.
    @Published var requestState: RequestState
    
    /// The requirements to be gathered by the user.
    @Published var requirements: [RequirementState] = []
    
    /// If all requirements are satisfied, complete button is enabled.
    @Published var isCompleteButtonEnabled: Bool = false
    
    /// Show a progress view when while doing internal logic.
    @Published var isProgressViewShowing: Bool = true
    
    /// List of issued Verified Ids.
    @Published var issuedVerifiedIds: [VerifiedId]
    
    /// The Verified Id Client is used to create requests with a configuration set by the Builder.
    private let verifiedIdClient: VerifiedIdClient
    
    /// The current issuance or presentation request that is being processed.
    var request: (any VerifiedIdRequest)? = nil
    
    /// Repository in charge of storing/retrieving verified ids.
    private let verifiedIdRepository: VerifiedIdRepository
    
    /// TODO: enable deeplinking and the rest of the requirements.
    init() {
        requestState = .Initialized
        
        // The VerifiedId is configured and built by the VerifiedIdClientBuilder.
        let builder = VerifiedIdClientBuilder()
        verifiedIdClient = builder.build()
        
        verifiedIdRepository = VerifiedIdRepository(verifiedIdClient: verifiedIdClient)
        issuedVerifiedIds = verifiedIdRepository.getAllStoredVerifiedIds()
    }
    
    /// Create request using Wallet Library and configure requirements to be shown.
    func createRequest(fromInput input: String) {
        
        Task {
            reset()
            requestState = .CreatingRequest
            do {
                
                let input: VerifiedIdRequestInput = try createInput(fromInput: input)
                
                // VerifiedIdClient is used to create a request from an input
                // such as, in this case, a VerifiedIdRequestURL.
                let result = await verifiedIdClient.createRequest(from: input)
                
                switch result {
                case .success(let request):
                    self.request = request
                    try configureRequirements(requirement: request.requirement)
                    isCompleteButtonEnabled = request.isSatisfied()
                    requestState = .GatheringRequirements
                case .failure(let error):
                    showErrorMessage(from: error, additionalInfo: "Unable to create request.")
                }
            } catch {
                showErrorMessage(from: error, additionalInfo: "Unable to create request.")
            }
        }
    }
    
    private func createInput(fromInput input: String) throws -> VerifiedIdRequestInput {
        
        guard let openidUrl = URL(string: input) else {
            throw SampleViewModelError.unableToCreateInput
        }
        
        return VerifiedIdRequestURL(url: openidUrl)
    }
    
    // Associate each requirement with a RequirementState for views.
    private func configureRequirements(requirement: Requirement) throws {
        
        // If a request has more than one requirement, they will be contained in a GroupRequirement.
        if let groupRequirement = requirement as? GroupRequirement {
            for req in groupRequirement.requirements {
                try configureRequirements(requirement: req)
            }
            return
        }
        
        let requirementState = try RequirementState(requirement: requirement)
        requirements.append(requirementState)
    }
    
    /// The helper method `getMatches` can be used to filter a list of Verified Ids and returns only the ones that satisfy the requirement.
    func getVerifiedIdMatches(from requirement: VerifiedIdRequirement) -> [VerifiedId] {
        return requirement.getMatches(verifiedIds: issuedVerifiedIds)
    }
    
    /// Once the request is satisfied, complete the request.
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
                issuedVerifiedIds.append(verifiedId)
                try verifiedIdRepository.save(verifiedId: verifiedId)
                requestState = .IssuanceSuccess(with: verifiedId)
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
                requestState = .PresentationSuccess(with: "Successful Presentation!")
            case .failure(let error):
                showErrorMessage(from: error)
            }
        }
    }
    
    /// Fulfill a requirement with a string value.
    func fulfill(requirementState: RequirementState, with value: String) throws {
        do {
            try requirementState.fulfill(with: value)
            isCompleteButtonEnabled = request?.isSatisfied() ?? false
        } catch let error as RequirementStateError {
            showErrorMessage(from: error,
                             additionalInfo: "Value == \(value)")
        }
    }
    
    /// Fulfill a requirement with a Verified id value.
    func fulfill(requirementState: RequirementState, with value: VerifiedId) throws {
        do {
            try requirementState.fulfill(with: value)
        } catch let error as RequirementStateError {
            showErrorMessage(from: error,
                             additionalInfo: "Value == \(value)")
        }
        self.isCompleteButtonEnabled = request?.isSatisfied() ?? false
    }
    
    /// If an error occurs during the flow, show the error message.
    func showErrorMessage(from error: Error, additionalInfo: String? = nil) {
        var errorMessage = String(describing: error)
        if let error = error as? SampleViewModelError {
            errorMessage = error.rawValue
        } else if let error = error as? RequirementStateError {
            errorMessage = error.rawValue
        }
        
        if let additionalInfo = additionalInfo {
            errorMessage.append("\n\(additionalInfo)")
        }
        requestState = .Error(withMessage: errorMessage)
    }
    
    /// Delete a verified id from list.
    func deleteVerifiedId(indexSet: IndexSet) {
        for index in indexSet {
            if issuedVerifiedIds.count > index {
                let verifiedId = issuedVerifiedIds[index]
                issuedVerifiedIds.remove(at: index)
                try? verifiedIdRepository.delete(verifiedId: verifiedId)
            }
        }
    }
    
    /// Reset to start a new request.
    func reset() {
        requestState = .Initialized
        requirements = []
        request = nil
    }
}
