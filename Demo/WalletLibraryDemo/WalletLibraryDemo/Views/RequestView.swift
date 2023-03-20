/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct RequestView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        switch (viewModel.viewState) {
        case .CreatingRequest:
            ProgressView()
        case .GatheringRequirements:
            requirementsView
        case .IssuanceSuccess(with: let verifiedId):
            VerifiedIdView(verifiedId: verifiedId)
        case .Error(withMessage: let message):
            ErrorView(errorMessage: message)
        default:
            Spacer()
        }
    }
    
    var requirementsView: some View {
        VStack {
            List(viewModel.requirements) { requirement in
                NavigationLink(destination: RequirementView(requirement: requirement)) {
                    RequirementListViewCell(requirement: requirement)
                }
            }.listStyle(.inset)
            Spacer()
            Divider()
            Button {
                viewModel.complete()
            } label: {
                Text("Complete")
            }.disabled(!viewModel.isCompleteButtonEnabled)
            Spacer()
        }.navigationTitle("Fulfill Requirements")
            .navigationBarTitleDisplayMode(.inline)
    }
}
