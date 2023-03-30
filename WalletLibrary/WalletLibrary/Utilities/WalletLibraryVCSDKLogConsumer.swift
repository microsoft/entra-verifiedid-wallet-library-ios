/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 *  A VC Log Consumer that can be injected into the VC SDK and route to Wallet Library Logger.
 */
struct WalletLibraryVCSDKLogConsumer: VCLogConsumer {
    
    private let logger: WalletLibraryLogger
    
    init(logger: WalletLibraryLogger) {
        self.logger = logger
    }
    
    func log(_ traceLevel: VCTraceLevel, message: String, functionName: String, file: String, line: Int) {
        logger.log(convertVCTraceLevelToWalletLibraryTraceLevel(traceLevel),
                   message: message,
                   functionName: functionName,
                   file: file,
                   line: line)
    }
    
    func event(name: String, properties: [String : String]?, measurements: [String : NSNumber]?) {
        logger.event(name: name, properties: properties, measurements: measurements)
    }
    
    /// TODO: converge VCLogger and Wallet Library Logger.
    private func convertVCTraceLevelToWalletLibraryTraceLevel(_ traceLevel: VCTraceLevel) -> TraceLevel {
        switch traceLevel {
        case .INFO:
            return .INFO
        case .VERBOSE:
            return .VERBOSE
        case .DEBUG:
            return .DEBUG
        case .WARN:
            return .WARN
        case .ERROR:
            return .ERROR
        case .FAILURE:
            return .FAILURE
        }
    }
}
