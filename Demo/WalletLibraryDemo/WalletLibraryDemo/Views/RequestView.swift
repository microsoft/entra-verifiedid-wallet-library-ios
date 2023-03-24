/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct RequestView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    var body: some View {
        switch (viewModel.requestState) {
        case .CreatingRequest:
            ProgressView()
        case .GatheringRequirements:
            RequirementListView()
        case .IssuanceSuccess(with: let verifiedId):
            VerifiedIdView(verifiedId: verifiedId)
        case .PresentationSuccess(with: let message):
            Text(message)
                .bold()
        case .Error(withMessage: let message):
            ErrorView(errorMessage: message)
        default:
            Spacer()
        }
    }
}
