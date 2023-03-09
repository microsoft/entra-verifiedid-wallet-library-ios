/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct RequestView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if viewModel.isProgressViewShowing {
                ProgressView()
            }
            else if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage)
            }
            else if viewModel.successMessage != nil || viewModel.issuedVerifiedId != nil {
                SuccessView()
            } else {
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
    }
}
