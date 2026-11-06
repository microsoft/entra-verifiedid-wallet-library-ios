/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 *  A VC Log Consumer that can be injected into the VC SDK and route to Wallet Library Logger.
 */
final class WalletLibraryVCSDKLogConsumer: VCLogConsumer {

    private final class LoggerReference {
        weak var logger: WalletLibraryLogger?

        init(_ logger: WalletLibraryLogger) {
            self.logger = logger
        }
    }

    private static let shared = WalletLibraryVCSDKLogConsumer()
    private static let registration: Void = {
        _ = VerifiableCredentialSDK.initialize(logConsumer: shared)
    }()

    private let lock = NSLock()
    private var loggers: [LoggerReference] = []

    private init() {}
    
    init(logger: WalletLibraryLogger) {
        loggers = [LoggerReference(logger)]
    }

    static func register(logger: WalletLibraryLogger) {
        _ = registration
        shared.lock.lock()
        defer { shared.lock.unlock() }
        shared.loggers.removeAll { $0.logger == nil }
        if !shared.loggers.contains(where: { $0.logger === logger }) {
            shared.loggers.append(LoggerReference(logger))
        }
    }

    private func consumers() -> [WalletLibraryLogConsumer] {
        lock.lock()
        let activeLoggers = loggers.compactMap { $0.logger }
        lock.unlock()

        var seen = Set<ObjectIdentifier>()
        return activeLoggers.flatMap { $0.consumers }.filter { consumer in
            // Value-type consumers retain their independent per-client registrations.
            guard type(of: consumer) is AnyClass else { return true }
            return seen.insert(ObjectIdentifier(consumer as AnyObject)).inserted
        }
    }
    
    func log(_ traceLevel: VCTraceLevel, message: String, functionName: String, file: String, line: Int) {
        for consumer in consumers() {
            consumer.log(convertVCTraceLevelToWalletLibraryTraceLevel(traceLevel),
                         message: message,
                         functionName: functionName,
                         file: file,
                         line: line)
        }
    }
    
    func event(name: String, properties: [String : String]?, measurements: [String : NSNumber]?) {
        for consumer in consumers() {
            consumer.event(name: name, properties: properties, measurements: measurements)
        }
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
