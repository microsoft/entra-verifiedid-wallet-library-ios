/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct WalletLibraryLogger {
    
    public static var sharedInstance = WalletLibraryLogger()
    
    private var consumers: [WalletLibraryLogConsumer] = []
    
    public mutating func add(consumer: WalletLibraryLogConsumer) {
        consumers.append(consumer)
    }
    
    public func logVerbose(message: String,
                           functionName: String = #function,
                           file: String = #file,
                           line: Int = #line) {
        log(.VERBOSE,
            message: message,
            functionName: functionName,
            file: file,
            line: line)
    }
    
    public func logDebug(message: String,
                         functionName: String = #function,
                         file: String = #file,
                         line: Int = #line) {
        log(.DEBUG,
            message: message,
            functionName: functionName,
            file: file,
            line: line)
    }
    
    public func logInfo(message: String,
                        functionName: String = #function,
                        file: String = #file,
                        line: Int = #line) {
        log(.INFO,
            message: message,
            functionName: functionName,
            file: file,
            line: line)
    }
    
    public func logWarning(message: String,
                           functionName: String = #function,
                           file: String = #file,
                           line: Int = #line) {
        log(.WARN,
            message: message,
            functionName: functionName,
            file: file,
            line: line)
    }
    
    public func logError(message: String,
                         functionName: String = #function,
                         file: String = #file,
                         line: Int = #line) {
        log(.ERROR,
            message: message,
            functionName: functionName,
            file: file,
            line: line)
    }
    
    public func logFailure(message: String,
                           functionName: String = #function,
                           file: String = #file,
                           line: Int = #line) {
        log(.FAILURE,
            message: message,
            functionName: functionName,
            file: file,
            line: line)
    }
    
    private func log(_ traceLevel: TraceLevel,
                            message: String,
                            functionName: String,
                            file: String,
                            line: Int) {
        consumers.forEach { logger in
            logger.log(traceLevel,
                       message: message,
                       functionName: functionName,
                       file: file,
                       line: line)
        }
    }
    
    public func event(name: String, properties: [String: String]? = nil, measurements: [String: NSNumber]? = nil) {
        consumers.forEach { logger in
            logger.event(name: name, properties: properties, measurements: measurements)
        }
    }
    
}
