/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import SwiftUI
import CoreData
import WalletLibrary

struct ContentView: UIViewControllerRepresentable {
    typealias UIViewControllerType = RequirementsViewController
    
    func makeUIViewController(context: Context) -> RequirementsViewController {
        return RequirementsViewController()
    }
    
    func updateUIViewController(_ uiViewController: RequirementsViewController, context: Context) {
//        print(context)
    }
}
