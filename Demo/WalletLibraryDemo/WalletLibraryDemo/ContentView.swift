/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import CoreData
import WalletLibrary

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = SampleViewModel()
    
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
            }.onDisappear {
                viewModel.createRequest()
            }
        }
        .environmentObject(viewModel)
    }
}
