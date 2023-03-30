/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class WalletLibraryLoggerTests: XCTestCase {
    
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
    
    func testDebug_WithMockConsumer_LogsInMockConsumer() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .DEBUG)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let logger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        
        // Act
        logger.logDebug(message: mockMessage,
                        functionName: mockFunctionName,
                        file: mockFile,
                        line: mockLine)
    }
    
    func testInfo_WithMockConsumer_LogsInMockConsumer() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .INFO)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let logger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        
        // Act
        logger.logInfo(message: mockMessage,
                       functionName: mockFunctionName,
                       file: mockFile,
                       line: mockLine)
    }
    
    func testVerbose_WithMockConsumer_LogsInMockConsumer() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .VERBOSE)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let logger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        
        // Act
        logger.logVerbose(message: mockMessage,
                          functionName: mockFunctionName,
                          file: mockFile,
                          line: mockLine)
    }
    
    func testWarn_WithMockConsumer_LogsInMockConsumer() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .WARN)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let logger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        
        // Act
        logger.logWarning(message: mockMessage,
                          functionName: mockFunctionName,
                          file: mockFile,
                          line: mockLine)
    }
    
    func testFailure_WithMockConsumer_LogsInMockConsumer() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .FAILURE)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let logger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        
        // Act
        logger.logFailure(message: mockMessage,
                          functionName: mockFunctionName,
                          file: mockFile,
                          line: mockLine)
    }
    
    func testError_WithMockConsumer_LogsInMockConsumer() async throws {
        // Arrange
        let testLogConsumer = testLogConsumer(with: .ERROR)
        let mockWalletLibraryLogConsumer = MockLogConsumer(logCallback: testLogConsumer)
        let logger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        
        // Act
        logger.logError(message: mockMessage,
                        functionName: mockFunctionName,
                        file: mockFile,
                        line: mockLine)
    }
    
    func testEvent_WitMockConsumer_LogsInMockConsumer() async throws {
        // Arrange
        let mockName = "mock message"
        func eventCalled(name: String) {
            XCTAssertEqual(name, mockName)
        }
        
        let mockWalletLibraryLogConsumer = MockLogConsumer(eventCallback: eventCalled)
        let logger = WalletLibraryLogger(consumers: [mockWalletLibraryLogConsumer])
        
        // Act
        logger.event(name: mockName)
    }
}
