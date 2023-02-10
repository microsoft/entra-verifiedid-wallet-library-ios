/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/// The trace level of the data that will be logged.
public enum TraceLevel {
    case VERBOSE
    case DEBUG
    case INFO
    case WARN
    case ERROR
    case FAILURE
}

/**
 * Protocol for consumers of the library to use to inject logging into the library.
 */
public protocol WalletLibraryLogConsumer {
    
    /// Logs a trace with calling function name, line, file.
    func log(_ traceLevel: TraceLevel,
             message: String,
             functionName: String,
             file: String,
             line: Int)
    
    /// Creates an event with with event name and properties.
    func event(name: String, properties: [String: String]?, measurements: [String: NSNumber]?)
}
