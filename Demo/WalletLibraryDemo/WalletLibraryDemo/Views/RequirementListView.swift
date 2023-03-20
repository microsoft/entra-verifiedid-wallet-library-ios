/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct RequirementListView: View {
    
    @EnvironmentObject var viewModel: SampleViewModel
    
    var body: some View {
        VStack {
            List(viewModel.requirements) { requirement in
                NavigationLink(destination: RequirementView(requirement: requirement)) {
                    RequirementListViewCell(requirement: requirement)
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
