/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import WalletLibrary

struct VerifiedIdPickerView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    @Environment(\.dismiss) var dismiss
    
    let requirement: RequirementState
    
    let requirementMatches: [VerifiedId]
    
    var body: some View {
        List(requirementMatches, id: \.id) { match in
            Button {
                fulfill(with: match)
            } label: {
                Text(match.style.name)
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
