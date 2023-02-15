/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockLogConsumer: WalletLibraryLogConsumer, Equatable {
    
    func log(_ traceLevel: TraceLevel,
             message: String,
             functionName: String,
             file: String,
             line: Int) {}
    
    func event(name: String,
               properties: [String : String]?,
               measurements: [String : NSNumber]?) {}
}
