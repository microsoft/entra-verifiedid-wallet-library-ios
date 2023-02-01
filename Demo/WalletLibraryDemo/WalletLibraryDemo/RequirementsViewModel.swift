/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import WalletLibrary

class RequirementsViewModel {
    
    private var verifiedIdUseCase: VerifiedIdUseCase
    
    private var verifiedIdRequest: (any VerifiedIdRequest)?
    
    var selfAttestedRequirements: Observer<[MockRequirement]>
    
    var isFlowComplete: Observer<VerifiedId?>
    
    var areAllRequirementsFulfilled: Observer<Bool>
    
    init() {
        self.verifiedIdUseCase = VerifiedIdUseCase()
        self.selfAttestedRequirements = Observer([])
        self.isFlowComplete = Observer(nil)
        self.areAllRequirementsFulfilled = Observer(false)
    }
    
    func createVerifiedIdRequest(from uri: String) throws {
        Task {
            do {
                let mockInput = try URLInput(url: uri)
                let request = try await verifiedIdUseCase.createVerifiedIdRequest(from: mockInput)
                initializeRequest(request: request)
            } catch {
                print(error)
            }
        }
    }
    
    private func initializeRequest(request: some VerifiedIdRequest) {
        self.verifiedIdRequest = request
        self.selfAttestedRequirements.value = [verifiedIdRequest?.requirement as! MockRequirement]
    }
    
    func fulfillRequirement(requirement: MockRequirement, with value: String) {
        requirement.fulfill(with: value)
        areAllRequirementsFulfilled.value = validate()
    }
    
    func validate() -> Bool {
        if let verifiedIdRequest = self.verifiedIdRequest {
            return validate(request: verifiedIdRequest)
        }
        
        return false
    }
    
    private func validate(request: some VerifiedIdRequest) -> Bool {
        return request.isSatisfied()
    }
    
    func completeFlow() {
        Task {
//            if let verifiedIdRequest = self.verifiedIdRequest as? VerifiedIdIssuanceRequest {
//                await completeFlow(request: verifiedIdRequest)
//            }
        }
    }
    
    private func completeFlow(request: any VerifiedIdIssuanceRequest) async {
        let result = await request.complete()
        
        switch result {
        case .success(let verifiedId):
            print(verifiedId)
            isFlowComplete.value = verifiedId
        case .failure(let error):
            print(error)
        }
    }
}
