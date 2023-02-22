/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct RequestView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if viewModel.isProgressViewShowing {
                ProgressView()
            }
            else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                Button {
                    viewModel.reset()
                    dismiss()
                } label: {
                    Text("Reset")
                }
            }
            else if let successMessage = viewModel.successMessage {
                Text(successMessage)
                Button {
                    viewModel.reset()
                    dismiss()
                } label: {
                    Text("Reset")
                }
            }
            else {
                List(viewModel.requirements) { requirement in
                    NavigationLink(destination: RequirementView(requirement: requirement)) {
                        HStack {
                            if requirement.status == .valid {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            Text(requirement.label)
                        }
                    }
                }
                Button {
                    viewModel.complete()
                } label: {
                    Text("Complete")
                }.disabled(!viewModel.isCompleteButtonEnabled)
            }
        }
    }
}

