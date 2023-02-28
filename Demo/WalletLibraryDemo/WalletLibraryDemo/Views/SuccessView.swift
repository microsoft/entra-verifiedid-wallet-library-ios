/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct SuccessView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if let successMessage = viewModel.successMessage {
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
                    if let expiresOn = issuedVerifiedId.expiresOn {
                        Text("Expires on: \(expiresOn.formatted())")
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    Text("Claims:")
                    let claims = issuedVerifiedId.getClaims()
                    List(claims.indices, id: \.self) { index in
                        HStack {
                            let claim = claims[index]
                            Text("\(claim.id):")
                            Text(String(describing: claims[index].value))
                        }
                    }.listStyle(.inset)
                }.navigationTitle("Verified Id Successfully Issued!")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

