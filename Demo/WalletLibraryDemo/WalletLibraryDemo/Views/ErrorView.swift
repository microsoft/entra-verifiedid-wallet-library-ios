/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct ErrorView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    let errorMessage: String
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text(errorMessage)
                .foregroundColor(.red)
            Button {
                viewModel.reset()
                dismiss()
            } label: {
                Text("Reset")
            }
        }
    }
}

