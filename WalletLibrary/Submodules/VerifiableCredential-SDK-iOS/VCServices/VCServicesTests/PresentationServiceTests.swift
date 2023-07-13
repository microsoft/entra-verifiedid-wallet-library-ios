/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationServiceTests: XCTestCase {
    
    var service: PresentationService!
    var presentationRequest: PresentationRequest!
    var mockIdentifier: Identifier!
    let identifierDB = IdentifierDatabase()
    let identifierCreator = IdentifierCreator()
    let expectedUrl = "openid://vc/?request_uri=https://test-relyingparty.azurewebsites.net/request/UZWlr4uOY13QiA"
    
    override func setUpWithError() throws {
        let formatter = PresentationResponseFormatter()
        let identifierService = IdentifierService()
        service = PresentationService(formatter: formatter,
                                      presentationApiCalls: MockPresentationApiCalls(),
                                      didDocumentDiscoveryApiCalls: MockDiscoveryApiCalls(),
                                      requestValidator: MockPresentationRequestValidator(),
                                      linkedDomainService: LinkedDomainService(),
                                      identifierService: identifierService)
        
        let token = PresentationRequestToken(from: TestData.presentationRequest.rawValue)!
        self.presentationRequest = PresentationRequest(from: token, linkedDomainResult: .linkedDomainVerified(domainUrl: "test.com"))
        
        self.mockIdentifier = try identifierCreator.create(forId: "master", andRelyingParty: "master")
        
        try identifierDB.saveIdentifier(identifier: mockIdentifier)
        
        MockPresentationResponseFormatter.wasFormatCalled = false
        MockPresentationApiCalls.wasPostCalled = false
        MockPresentationApiCalls.wasGetCalled = false
        MockDiscoveryApiCalls.wasGetCalled = false
        MockPresentationRequestValidator.wasValidateCalled = false
    }
    
    override func tearDownWithError() throws {
        try CoreDataManager.sharedInstance.deleteAllIdentifiers()
    }
    
    func testInit() {
        let service = IssuanceService()
        XCTAssertNotNil(service.formatter)
        XCTAssertNotNil(service.apiCalls)
    }
    
    func testGetRequest() async throws {
        do {
            // Act
            let _ = try await service.getRequest(usingUrl: expectedUrl)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(MockPresentationApiCalls.wasGetCalled)
            XCTAssert(error is MockPresentationNetworkingError)
        }
    }
    
    func testGetRequestMalformedUri() async throws {
        // Arrange
        let malformedUrl = "//|\\"
        
        do {
            // Act
            let _ = try await service.getRequest(usingUrl: malformedUrl)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(error is PresentationServiceError)
            XCTAssertEqual(error as? PresentationServiceError, .inputStringNotUri)
        }
    }
    
    func testGetRequestNoQueryParameters() async throws {
        // Arrange
        let malformedUrl = "https://test.com"
        
        do {
            // Act
            let _ = try await service.getRequest(usingUrl: malformedUrl)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(error is PresentationServiceError)
            XCTAssertEqual(error as? PresentationServiceError, .noQueryParametersOnUri)
        }
    }
    
    func testGetRequestNoValueOnRequestUri() async throws {
        // Arrange
        let malformedUrl = "https://test.com?request_uri"
        
        do {
            // Act
            let _ = try await service.getRequest(usingUrl: malformedUrl)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(error is PresentationServiceError)
            XCTAssertEqual(error as? PresentationServiceError, .noValueForRequestUriQueryParameter)
        }
    }
    
    func testGetRequestNoRequestUri() async throws {
        // Arrange
        let malformedUrl = "https://test.com?testparam=33423"
        
        do {
            // Act
            let _ = try await service.getRequest(usingUrl: malformedUrl)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(error is PresentationServiceError)
            XCTAssertEqual(error as? PresentationServiceError, .noRequestUriQueryParameter)
        }
    }
    
    func testSendResponse() async throws {
        // Arrange
        let formatter = MockPresentationResponseFormatter(shouldSucceed: true)
        let identifierService = IdentifierService()
        let service = PresentationService(formatter: formatter,
                                          presentationApiCalls: MockPresentationApiCalls(),
                                          didDocumentDiscoveryApiCalls: MockDiscoveryApiCalls(),
                                          requestValidator: MockPresentationRequestValidator(),
                                          linkedDomainService: LinkedDomainService(),
                                          identifierService: identifierService)
        
        let response = try PresentationResponseContainer(from: self.presentationRequest)
        
        do {
            // Act
            try await service.send(response: response)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(MockPresentationResponseFormatter.wasFormatCalled)
            XCTAssert(MockPresentationApiCalls.wasPostCalled)
            XCTAssert(error is MockPresentationNetworkingError)
        }
    }
    
    func testSendResponseFailedToFormat() async throws {
        // Arrange
        let formatter = MockPresentationResponseFormatter(shouldSucceed: false)
        let identifierService = IdentifierService()
        let service = PresentationService(formatter: formatter,
                                          presentationApiCalls: MockPresentationApiCalls(),
                                          didDocumentDiscoveryApiCalls: MockDiscoveryApiCalls(),
                                          requestValidator: MockPresentationRequestValidator(),
                                          linkedDomainService: LinkedDomainService(),
                                          identifierService: identifierService)
        
        let response = try PresentationResponseContainer(from: self.presentationRequest)
        
        do {
            // Act
            try await service.send(response: response)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(MockPresentationResponseFormatter.wasFormatCalled)
            XCTAssertFalse(MockPresentationApiCalls.wasPostCalled)
            XCTAssert(error is MockIssuanceResponseFormatterError)
        }
    }
}
