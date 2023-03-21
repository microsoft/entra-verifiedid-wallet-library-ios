/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import WalletLibrary

struct VerifiedIdView: View {
    
    let verifiedId: VerifiedId
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("\(verifiedId.style.name)")
                .multilineTextAlignment(.center)
            Spacer()
            Text("Issued on: \(verifiedId.issuedOn.formatted())")
                .multilineTextAlignment(.center)
            Spacer()
            if let expiresOn = verifiedId.expiresOn {
                Text("Expires on: \(expiresOn.formatted())")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Text("Claims:")
            let claims = verifiedId.getClaims()
            List(claims.indices, id: \.self) { index in
                HStack {
                    let claim = claims[index]
                    Text("\(claim.id):")
                    Text(String(describing: claims[index].value))
                }
            }.listStyle(.inset)
        }.navigationTitle("Verified Id")
            .navigationBarTitleDisplayMode(.inline)
    }
}
