/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import WalletLibrary

struct RequirementView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var requirement: RequirementState
    
    var body: some View {
        switch (requirement.requirement) {
        case is SelfAttestedClaimRequirement:
            UserInputView(requirement: requirement)
        case is PinRequirement:
            UserInputView(requirement: requirement)
        case let verifiedIdRequirement as VerifiedIdRequirement:
            VerifiedIdPickerView(requirement: requirement,
                                 requirementMatches: viewModel.getVerifiedIdMatches(from: verifiedIdRequirement))
        default:
            Text("Do not support requirement.")
        }
    }
}
