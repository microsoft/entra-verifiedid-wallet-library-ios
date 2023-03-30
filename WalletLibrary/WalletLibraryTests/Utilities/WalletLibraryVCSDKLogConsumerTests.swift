/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class WalletLibraryVCSDKLogConsumerTests: XCTestCase {
    
    let mockMessage = "mock debug message"
    let mockFunctionName = "mock function"
    let mockFile = "mock file"
    let mockLine = 63
    
    private func testLogConsumer(with traceLevel: TraceLevel) -> ((TraceLevel, String, String, String, Int) -> ())? {
        func testLogConsumer(traceLevel: TraceLevel, message: String, functionName: String, file: String, line: Int) {
            // Assert
            XCTAssertEqual(traceLevel, traceLevel)
            XCTAssertEqual(message, mockMessage)
            XCTAssertEqual(functionName, mockFunctionName)
            XCTAssertEqual(file, mockFile)
            XCTAssertEqual(line, mockLine)
        }
        
        return testLogConsumer
    }
    
    func testlog_WithDebug_LogsInWalletLibraryLogger() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .DEBUG)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let walletLibraryLogger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        let walletLibraryVCSDKLogConsumer = WalletLibraryVCSDKLogConsumer(logger: walletLibraryLogger)
        
        // Act
        walletLibraryVCSDKLogConsumer.log(.DEBUG,
                                          message: mockMessage,
                                          functionName: mockFunctionName,
                                          file: mockFile,
                                          line: mockLine)
    }
    
    func testlog_WithInfo_LogsInWalletLibraryLogger() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .INFO)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let walletLibraryLogger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        let walletLibraryVCSDKLogConsumer = WalletLibraryVCSDKLogConsumer(logger: walletLibraryLogger)
        
        // Act
        walletLibraryVCSDKLogConsumer.log(.INFO,
                                          message: mockMessage,
                                          functionName: mockFunctionName,
                                          file: mockFile,
                                          line: mockLine)
    }
    
    func testlog_WithError_LogsInWalletLibraryLogger() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .ERROR)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let walletLibraryLogger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        let walletLibraryVCSDKLogConsumer = WalletLibraryVCSDKLogConsumer(logger: walletLibraryLogger)
        
        // Act
        walletLibraryVCSDKLogConsumer.log(.ERROR,
                                          message: mockMessage,
                                          functionName: mockFunctionName,
                                          file: mockFile,
                                          line: mockLine)
    }
    
    func testlog_WithFailure_LogsInWalletLibraryLogger() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .FAILURE)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let walletLibraryLogger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        let walletLibraryVCSDKLogConsumer = WalletLibraryVCSDKLogConsumer(logger: walletLibraryLogger)
        
        // Act
        walletLibraryVCSDKLogConsumer.log(.FAILURE,
                                          message: mockMessage,
                                          functionName: mockFunctionName,
                                          file: mockFile,
                                          line: mockLine)
    }
    
    func testlog_WithWarn_LogsInWalletLibraryLogger() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .WARN)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let walletLibraryLogger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        let walletLibraryVCSDKLogConsumer = WalletLibraryVCSDKLogConsumer(logger: walletLibraryLogger)
        
        // Act
        walletLibraryVCSDKLogConsumer.log(.WARN,
                                          message: mockMessage,
                                          functionName: mockFunctionName,
                                          file: mockFile,
                                          line: mockLine)
    }
    
    func testlog_WithVerbose_LogsInWalletLibraryLogger() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .VERBOSE)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let walletLibraryLogger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        let walletLibraryVCSDKLogConsumer = WalletLibraryVCSDKLogConsumer(logger: walletLibraryLogger)
        
        // Act
        walletLibraryVCSDKLogConsumer.log(.VERBOSE,
                                          message: mockMessage,
                                          functionName: mockFunctionName,
                                          file: mockFile,
                                          line: mockLine)
    }
    
    func testevent_WithMessage_LogsEventInWalletLibraryLogger() async throws {
        // Arrange
        let mockName = "mock message"
        func eventCalled(name: String) {
            XCTAssertEqual(name, mockName)
        }
        
        let mockWalletLibraryLogConsumer = MockLogConsumer(eventCallback: eventCalled)
        let walletLibraryLogger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        let walletLibraryVCSDKLogConsumer = WalletLibraryVCSDKLogConsumer(logger: walletLibraryLogger)
        
        // Act
        walletLibraryVCSDKLogConsumer.event(name: mockName,
                                            properties: nil,
                                            measurements: nil)
    }
}
