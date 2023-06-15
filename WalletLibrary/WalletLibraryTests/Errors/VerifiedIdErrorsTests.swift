/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdErrorsTests: XCTestCase {
    
    func testCreateNetworkingError_WithBadRequestErrorInput_ReturnsError() async throws {
        // Arrange
        let mockBody = "Mock Body"
        let mockStatusCode = 401
        let mockVCNetworkingError = NetworkingError.badRequest(withBody: mockBody, statusCode: mockStatusCode)
        
        // Act
        let result = VerifiedIdErrors.VCNetworkingError(error: mockVCNetworkingError).error as! VerifiedIdNetworkingError
        
        // Assert
        XCTAssertEqual(result.statusCode, mockStatusCode)
        XCTAssertEqual(result.message, "Bad Request")
        XCTAssertEqual(result.code, VerifiedIdErrors.ErrorCode.NetworkingError)
        if case NetworkingError.badRequest(let body, let statusCode) = (result.innerError as! NetworkingError) {
            XCTAssertEqual(body, mockBody)
            XCTAssertEqual(statusCode, mockStatusCode)
        }
    }
    
    func testCreateNetworkingError_WithForbiddenErrorInput_ReturnsError() async throws {
        // Arrange
        let mockBody = "Mock Body"
        let mockStatusCode = 401
        let mockVCNetworkingError = NetworkingError.forbidden(withBody: mockBody, statusCode: mockStatusCode)
        
        // Act
        let result = VerifiedIdErrors.VCNetworkingError(error: mockVCNetworkingError).error as! VerifiedIdNetworkingError
        
        // Assert
        XCTAssertEqual(result.statusCode, mockStatusCode)
        XCTAssertEqual(result.message, "Forbidden")
        XCTAssertEqual(result.code, VerifiedIdErrors.ErrorCode.NetworkingError)
        if case NetworkingError.forbidden(let body, let statusCode) = (result.innerError as! NetworkingError) {
            XCTAssertEqual(body, mockBody)
            XCTAssertEqual(statusCode, mockStatusCode)
        }
    }
    
    func testCreateNetworkingError_WithNotFoundErrorInput_ReturnsError() async throws {
        // Arrange
        let mockBody = "Mock Body"
        let mockStatusCode = 401
        let mockVCNetworkingError = NetworkingError.notFound(withBody: mockBody, statusCode: mockStatusCode)
        
        // Act
        let result = VerifiedIdErrors.VCNetworkingError(error: mockVCNetworkingError).error as! VerifiedIdNetworkingError
        
        // Assert
        XCTAssertEqual(result.statusCode, mockStatusCode)
        XCTAssertEqual(result.message, "Not Found")
        XCTAssertEqual(result.code, VerifiedIdErrors.ErrorCode.NetworkingError)
        if case NetworkingError.notFound(let body, let statusCode) = (result.innerError as! NetworkingError) {
            XCTAssertEqual(body, mockBody)
            XCTAssertEqual(statusCode, mockStatusCode)
        }
    }
    
    func testCreateNetworkingError_WithServerErrorErrorInput_ReturnsError() async throws {
        // Arrange
        let mockBody = "Mock Body"
        let mockStatusCode = 401
        let mockVCNetworkingError = NetworkingError.serverError(withBody: mockBody, statusCode: mockStatusCode)
        
        // Act
        let result = VerifiedIdErrors.VCNetworkingError(error: mockVCNetworkingError).error as! VerifiedIdNetworkingError
        
        // Assert
        XCTAssertEqual(result.statusCode, mockStatusCode)
        XCTAssertEqual(result.message, "Server Error")
        XCTAssertEqual(result.code, VerifiedIdErrors.ErrorCode.NetworkingError)
        if case NetworkingError.serverError(let body, let statusCode) = (result.innerError as! NetworkingError) {
            XCTAssertEqual(body, mockBody)
            XCTAssertEqual(statusCode, mockStatusCode)
        }
    }
    
    func testCreateNetworkingError_WithUnknownNetworkingErrorInput_ReturnsError() async throws {
        // Arrange
        let mockBody = "Mock Body"
        let mockStatusCode = 401
        let mockVCNetworkingError = NetworkingError.unknownNetworkingError(withBody: mockBody, statusCode: mockStatusCode)
        
        // Act
        let result = VerifiedIdErrors.VCNetworkingError(error: mockVCNetworkingError).error as! VerifiedIdNetworkingError
        
        // Assert
        XCTAssertEqual(result.statusCode, mockStatusCode)
        XCTAssertEqual(result.message, "Unknown Networking Error")
        XCTAssertEqual(result.code, VerifiedIdErrors.ErrorCode.NetworkingError)
        if case NetworkingError.unknownNetworkingError(let body, let statusCode) = (result.innerError as! NetworkingError) {
            XCTAssertEqual(body, mockBody)
            XCTAssertEqual(statusCode, mockStatusCode)
        }
    }
    
    func testCreateNetworkingError_WithUnspecifiedNetworkingErrorInput_ReturnsError() async throws {
        // Arrange
        let mockVCNetworkingError = NetworkingError.unableToParseString
        
        // Act
        let result = VerifiedIdErrors.VCNetworkingError(error: mockVCNetworkingError).error as! VerifiedIdNetworkingError
        
        // Assert
        XCTAssertNil(result.statusCode)
        XCTAssertEqual(result.message, "Unknown Networking Error")
        XCTAssertEqual(result.code, VerifiedIdErrors.ErrorCode.NetworkingError)
        XCTAssertEqual(NetworkingError.unableToParseString, result.innerError as! NetworkingError)
    }
}
