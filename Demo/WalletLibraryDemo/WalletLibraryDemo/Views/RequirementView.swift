/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import WalletLibrary

struct RequirementView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    @State private var userInput: String = ""
    
    @State private var isInvalidInput: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var requirement: RequirementState
    
    var body: some View {
        switch (requirement.requirement) {
        case is SelfAttestedClaimRequirement:
            UserInputView(requirement: requirement)
        case is PinRequirement:
            UserInputView(requirement: requirement)
        case let verifiedIdRequirement as VerifiedIdRequirement:
            let matches = verifiedIdRequirement.getMatches(verifiedIds: viewModel.issuedVerifiedIds)
            List(matches, id: \.id) { match in
                Button {
                    fulfill(with: match)
                } label: {
                    Text(match.id)
                }
            }.listStyle(.inset)
        default:
            Text("Do not support requirement.")
        }
    }
    
    private func fulfill(with value: VerifiedId) {
        do {
            try viewModel.fulfill(requirementState: requirement, with: value)
            dismiss()
        } catch {
            isInvalidInput = true
        }
    }
}
