/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import CoreData
import WalletLibrary
import AuthenticationServices

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sample Request URL:")
                TextField(
                    "OpenId Request URL",
                    text: $viewModel.input,
                    axis: .vertical
                )
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .frame(width: UIScreen.main.bounds.width - 20)
                NavigationLink(destination: RequestView()) {
                    Text("Create Request")
                }.navigationTitle("Verified Id Sample App")
                Button {
                    test()
                } label: {
                    Text("deeplink")
                }
                Button {
                    aswebtest()
                } label: {
                    Text("ASWebAuthenticatioSession")
                }
            }.onDisappear {
                viewModel.createRequest()
            }
        }
        .environmentObject(viewModel)
    }
    
    private func test() {
        let url = URL(string: "https://myaccount.microsoft.com/")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func aswebtest() {
        viewModel.testAuthService()
    }
}
