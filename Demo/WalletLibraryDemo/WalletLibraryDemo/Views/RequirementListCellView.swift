/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI

struct RequirementListViewCell: View {
    
    @StateObject var requirement: RequirementState
    
    var body: some View {
        HStack {
            switch (requirement.status) {
            case .valid:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .invalid:
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
            case .missing:
                Image(systemName: "circle.fill")
                    .foregroundColor(.accentColor)
            }
            Text(requirement.label)
        }
    }
}

