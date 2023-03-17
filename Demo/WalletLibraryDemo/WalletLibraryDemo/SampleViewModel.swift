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
}

enum ViewState {
    case Initialized
    case InProgress
    case GatheringRequirements
    case IssuanceSuccess(with: VerifiedId)
    case PresentationSuccess(with: String)
    case Error(withMessage: String)
}


@MainActor class SampleViewModel: ObservableObject {
    
    @Published var viewState: ViewState
    
    /// The requirements to be gathered by the user.
    @Published var requirements: [RequirementState] = []
    
    /// If all requirements are satisfied, complete button is enabled.
    @Published var isCompleteButtonEnabled: Bool = false
    
    /// Show a progress view when while doing internal logic.
    @Published var isProgressViewShowing: Bool = true
    
    @Published var issuedVerifiedIds: [VerifiedId] = []
    
    /// The Verified Id Client is used to create requests with a configuration set by the Builder.
    private let verifiedIdClient: VerifiedIdClient?
    
    /// The current issuance or presentation request that is being processed.
    private var request: (any VerifiedIdRequest)? = nil
    
    private let verifiedIdRepository = VerifiedIdRepository()
    
    /// TODO: enable deeplinking and the rest of the requirements.
    init() {
        viewState = .Initialized
        do {
            let builder = VerifiedIdClientBuilder()
            issuedVerifiedIds = try verifiedIdRepository.getAllStoredVerifiedIds()
            verifiedIdClient = try builder.build()
        } catch {
            verifiedIdClient = nil
            showErrorMessage(from: error)
        }
    }
    
    func createRequest(fromInput input: String) {
        
        guard let client = verifiedIdClient else {
            showErrorMessage(from: SampleViewModelError.unableToCreateRequest)
            return
        }
        
        Task {
            reset()
            viewState = .InProgress
            do {
                
                let input: VerifiedIdRequestInput = try createInput(fromInput: input)
                
                // VerifiedIdClient is used to create a request from an input
                // such as, in the case, a VerifiedIdRequestURL.
                let request = try await client.createVerifiedIdRequest(from: input)
                self.request = request
                
                try configureRequirements(requirement: request.requirement)
                isCompleteButtonEnabled = request.isSatisfied()
                viewState = .GatheringRequirements
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
                viewState = .IssuanceSuccess(with: verifiedId)
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
                viewState = .PresentationSuccess(with: "Successful Presentation!")
            case .failure(let error):
                showErrorMessage(from: error)
            }
        }
    }
    
    func fulfill(requirementState: RequirementState, with value: String) throws {
        do {
            try requirementState.fulfill(with: value)
        } catch let error as RequirementStateError {
            showErrorMessage(from: error,
                             additionalInfo: "Value == \(value)")
        }
        self.isCompleteButtonEnabled = request?.isSatisfied() ?? false
    }
    
    func fulfill(requirementState: RequirementState, with value: VerifiedId) throws {
        do {
            try requirementState.fulfill(with: value)
        } catch let error as RequirementStateError {
            showErrorMessage(from: error,
                             additionalInfo: "Value == \(value)")
        }
        self.isCompleteButtonEnabled = request?.isSatisfied() ?? false
    }
    
    private func showErrorMessage(from error: Error, additionalInfo: String? = nil) {
        print(error)
        var errorMessage: String = error.localizedDescription
        if let error = error as? SampleViewModelError {
            errorMessage = error.rawValue
        } else if let error = error as? RequirementStateError {
            errorMessage = error.rawValue
        }
        
        if let additionalInfo = additionalInfo {
            errorMessage.append("\n\(additionalInfo)")
        }
        viewState = .Error(withMessage: errorMessage)
    }
    
    func deleteVerifiedId(indexSet: IndexSet) {
        for index in indexSet {
            if issuedVerifiedIds.count > index {
                let verifiedId = issuedVerifiedIds[index]
                issuedVerifiedIds.remove(at: index)
                try? verifiedIdRepository.delete(verifiedId: verifiedId)
            }
        }
    }
    
    func reset() {
        viewState = .Initialized
        requirements = []
        request = nil
    }
}
