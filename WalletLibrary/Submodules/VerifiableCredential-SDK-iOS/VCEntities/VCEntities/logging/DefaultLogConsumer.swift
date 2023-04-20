/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

public struct DefaultVCLogConsumer: VCLogConsumer {
    
    public init() {}
    
    public func log(_ traceLevel: VCTraceLevel,
                    message: String,
                    functionName: String = #function,
                    file: String = #file,
                    line: Int = #line) {
        print("\(traceLevel): \(message) \nAt: \(functionName), \(file), \(line)")
    }
    
    public func event(name: String, properties: [String : String]?, measurements: [String: NSNumber]? = nil) {
        print("\(name): with properties: \(String(describing: properties))")
    }
}
