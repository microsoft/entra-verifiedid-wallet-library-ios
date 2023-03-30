/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockLogConsumer: WalletLibraryLogConsumer, Equatable {
    
    let uuid = UUID()
    
    let logCallback: ((TraceLevel, String, String, String, Int) -> ())?
    
    let eventCallback: ((String) -> ())?
    
    init(logCallback: ((TraceLevel, String, String, String, Int) -> ())? = nil,
         eventCallback: ((String) -> ())? = nil) {
        self.logCallback = logCallback
        self.eventCallback = eventCallback
    }
    
    func log(_ traceLevel: TraceLevel,
             message: String,
             functionName: String,
             file: String,
             line: Int) {
        logCallback?(traceLevel, message, functionName, file, line)
    }
    
    func event(name: String,
               properties: [String : String]?,
               measurements: [String : NSNumber]?) {
        eventCallback?(name)
    }
    
    static func == (lhs: MockLogConsumer, rhs: MockLogConsumer) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
