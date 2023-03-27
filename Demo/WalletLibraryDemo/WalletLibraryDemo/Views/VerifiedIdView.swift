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
            Text("Abstract Values")
                .multilineTextAlignment(.center)
                .bold()
            Text("\(verifiedId.id)")
                .multilineTextAlignment(.center)
            Text("Issued on: \(verifiedId.issuedOn.formatted())")
                .multilineTextAlignment(.center)
            if let expiresOn = verifiedId.expiresOn {
                Text("Expires on: \(expiresOn.formatted())")
                    .multilineTextAlignment(.center)
            }
            if let basicStyle = verifiedId.style as? BasicVerifiedIdStyle {
                Divider()
                Text("Verified Id Basic Style")
                    .multilineTextAlignment(.center)
                    .bold()
                Text("Issuer: \(basicStyle.issuer)")
                Text("Description: \(basicStyle.description)")
                Text("Background Color: \(basicStyle.backgroundColor)")
                Text("Text Color: \(basicStyle.textColor)")
                Spacer()
                Divider()
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
        }.navigationTitle(verifiedId.style.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}
