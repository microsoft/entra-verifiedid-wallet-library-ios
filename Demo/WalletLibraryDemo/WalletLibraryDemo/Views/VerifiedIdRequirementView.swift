/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import WalletLibrary

struct VerifiedIdRequirementView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    @State private var userInput: String = ""
    
    @State private var isInvalidInput: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var requirement: RequirementState
    
    var requirementMatches: [VerifiedId]
    
    var body: some View {
        List(requirementMatches, id: \.id) { match in
            Button {
                fulfill(with: match)
            } label: {
                Text(match.id)
            }
        }.listStyle(.inset)
    }
    
    private func fulfill(with value: VerifiedId) {
        do {
            try viewModel.fulfill(requirementState: requirement, with: value)
        } catch {
            viewModel.showErrorMessage(from: error)
        }
        dismiss()
    }
}
