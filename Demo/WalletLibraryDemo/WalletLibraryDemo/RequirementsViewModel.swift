/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import WalletLibrary

class RequirementsViewModel {
    
    private var verifiedIdUseCase: VerifiedIdUseCase
    
    private var verifiedIdClient: (any VerifiedIdClient)?
    
    var selfAttestedRequirements: Observer<[MockRequirement]>
    
    var isFlowComplete: Observer<VerifiedId?>
    
    var areAllRequirementsFulfilled: Observer<Bool>
    
    init() {
        self.verifiedIdUseCase = VerifiedIdUseCase()
        self.selfAttestedRequirements = Observer([])
        self.isFlowComplete = Observer(nil)
        self.areAllRequirementsFulfilled = Observer(false)
    }
    
    func createVerifiedIdClient(from uri: String) throws {
        Task {
            let mockInput = MockVerifiedIdClientInput(uri: uri)
            let client = try await verifiedIdUseCase.createVerifiedIdClient(from: mockInput)
            initializeClient(client: client)
        }
    }
    
    private func initializeClient(client: some VerifiedIdClient) {
        self.verifiedIdClient = client
        self.selfAttestedRequirements.value = [verifiedIdClient?.requirement as! MockRequirement]
    }
    
    func fulfillRequirement(requirement: MockRequirement, with value: String) {
        requirement.fulfill(with: value)
        areAllRequirementsFulfilled.value = true
    }
    
    func validate() -> Bool {
        if let verifiedIdClient = self.verifiedIdClient {
            return validate(client: verifiedIdClient)
        }
        
        return false
    }
    
    private func validate(client: some VerifiedIdClient) -> Bool {
        return client.areAllRequirementsFulfilled()
    }
    
    func completeFlow() {
        Task {
            if let verifiedIdClient = self.verifiedIdClient as? VerifiedIdIssuanceClient {
                await completeFlow(client: verifiedIdClient)
            }
        }
    }
    
    private func completeFlow(client: VerifiedIdIssuanceClient) async {
        let result = await client.complete()
        
        switch result {
        case .success(let verifiedId):
            print(verifiedId)
            isFlowComplete.value = verifiedId
        case .failure(let error):
            print(error)
        }
    }
}
