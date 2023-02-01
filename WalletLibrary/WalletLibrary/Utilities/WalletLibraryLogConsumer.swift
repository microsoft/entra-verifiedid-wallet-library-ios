/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public enum TraceLevel {
    case VERBOSE
    case DEBUG
    case INFO
    case WARN
    case ERROR
    case FAILURE
}

public protocol WalletLibraryLogConsumer {
    /**
     Logs a trace with calling function name, line, file.
     - Parameters:
     - traceLevel: VCTraceLevel of the log like verbose, info
     */
    func log(_ traceLevel: TraceLevel,
             message: String,
             functionName: String,
             file: String,
             line: Int)
    
    /**
     Creates an event with with event name and properties.
     - Parameters:
     - name: Name of the class calling the function.
     - properties: dictionary of properties for the specific event.
     - measurements: dictionary of measurements taken.
     */
    func event(name: String, properties: [String: String]?, measurements: [String: NSNumber]?)
}
