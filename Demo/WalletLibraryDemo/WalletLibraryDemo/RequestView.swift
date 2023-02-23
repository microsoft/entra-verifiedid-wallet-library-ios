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
            else if let issuedVerifiedId = viewModel.issuedVerifiedId {
                VStack {
                    Text("\(issuedVerifiedId.id)")
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text("Issued on: \(issuedVerifiedId.issuedOn.formatted())")
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text("Expires on: \(issuedVerifiedId.expiresOn.formatted())")
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text("Claims:")
                        .multilineTextAlignment(.center)
                    List(issuedVerifiedId.claims.indices, id: \.self) { index in
                        HStack {
                            Text("\(issuedVerifiedId.claims[index].id):")
                            Text(String(describing: issuedVerifiedId.claims[index].value))
                        }
                    }.listStyle(.inset)
                }.navigationTitle("Verified Id Successfully Issued!")
                    .navigationBarTitleDisplayMode(.inline)
            }
            else {
                VStack {
                    List(viewModel.requirements) { requirement in
                        NavigationLink(destination: RequirementView(requirement: requirement)) {
                            HStack {
                                switch (requirement.status) {
                                case .valid:
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                case .invalid:
                                    Image(systemName: "x.circle.fill")
                                        .foregroundColor(.red)
                                case .missing:
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                                Text(requirement.label)
                            }
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

