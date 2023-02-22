/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import CoreData
import WalletLibrary

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sample Request URL:")
                TextField(
                    "OpenId Request URL",
                    text: $viewModel.input
                )
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .frame(width: UIScreen.main.bounds.width - 20)
                NavigationLink(destination: RequestView()) {
                    Text("Create Request")
                }.navigationTitle("Verified Id Sample App")
            }.onDisappear {
                viewModel.createRequest()
            }
        }
        .environmentObject(viewModel)
    }
}

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
                        Text(requirement.label)
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

struct RequirementView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var userInput: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var requirement: RequirementState
    
    var body: some View {
        VStack {
            Text(requirement.label)
            TextField(
                "",
                text: $userInput
            )
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .frame(width: UIScreen.main.bounds.width - 20)
            Button {
                fulfill(with: userInput)
            } label: {
                Text("Add")
            }
        }
    }
    
    private func fulfill(with value: String) {
        do {
            try viewModel.fulfill(requirementState: requirement, with: value)
            dismiss()
        } catch {
            print("invalid")
        }
    }
}

//struct PinRequirementView: View {
//
//    @EnvironmentObject var viewModel: ViewModel
//
//    var requirement: RequirementMapping
//
//    var body: some View {
//        VStack {
//            if let pinRequirement = requirement.requirement as? PinRequirement {
//                Text(pinRequirement.type)
//                Button {
//                    pinRequirement.fulfill(with: "test test test")
//                    viewModel.fulfill(requirement: pinRequirement, with: "test test test", id: requirement.id)
//                } label: {
//                    Text("add")
//                }
//            }
//        }
//    }
//}
