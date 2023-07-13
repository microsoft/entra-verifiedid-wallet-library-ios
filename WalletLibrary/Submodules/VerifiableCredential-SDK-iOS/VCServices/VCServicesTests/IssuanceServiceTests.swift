/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IssuanceServiceTests: XCTestCase {
    
    var service: IssuanceService!
    var contract: Contract!
    let expectedUrl = "https://test3523.com"
    var mockIdentifier: Identifier!
    let identifierDB = IdentifierDatabase()
    let identifierCreator = IdentifierCreator()

    override func setUpWithError() throws {
        let formatter = MockIssuanceResponseFormatter(shouldSucceed: true)
        service = IssuanceService(formatter: formatter,
                                  apiCalls: MockIssuanceApiCalls(),
                                  discoveryApiCalls: MockDiscoveryApiCalls(),
                                  requestValidator: MockIssuanceRequestValidator(),
                                  identifierService: IdentifierService(),
                                  linkedDomainService: LinkedDomainService())
        
        let encodedContract = TestData.aiContract.rawValue.data(using: .utf8)!
        self.contract = try JSONDecoder().decode(Contract.self, from: encodedContract)
        
        self.mockIdentifier = try identifierCreator.create(forId: "master", andRelyingParty: "master")
        
        try identifierDB.saveIdentifier(identifier: mockIdentifier)
        
        MockIssuanceResponseFormatter.wasFormatCalled = false
        MockIssuanceRequestValidator.wasValidateCalled = false
        MockDiscoveryApiCalls.wasGetCalled = false
        MockIssuanceApiCalls.wasPostResponseCalled = false
        MockIssuanceApiCalls.wasPostCompletionResponseCalled = false
    }
    
    override func tearDownWithError() throws {
        try CoreDataManager.sharedInstance.deleteAllIdentifiers()
    }
    
    func testPublicInit() {
        // Act
        let service = IssuanceService()
        
        // Assert
        XCTAssertNotNil(service.formatter)
        XCTAssertNotNil(service.apiCalls)
    }

    func testGetRequest() async throws {
        do {
            // Act
            let request = try await service.getRequest(usingUrl: expectedUrl)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(MockIssuanceApiCalls.wasGetCalled)
            XCTAssert(error is MockIssuanceNetworkingError)
        }
    }
    
    func testSendResponse() async throws {
        // Arrange
        let response = try IssuanceResponseContainer(from: contract, contractUri: expectedUrl)
        
        do {
            // Act
            let _ = try await service.send(response: response)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(MockIssuanceResponseFormatter.wasFormatCalled)
            XCTAssert(MockIssuanceApiCalls.wasPostResponseCalled)
            XCTAssert(error is MockIssuanceNetworkingError)
        }
    }
    
    func testSendResponseFailedToFormat() async throws {
        // Arrange
        let formatter = MockIssuanceResponseFormatter(shouldSucceed: false)
        let service = IssuanceService(formatter: formatter,
                                      apiCalls: MockIssuanceApiCalls(),
                                      discoveryApiCalls: MockDiscoveryApiCalls(),
                                      requestValidator: MockIssuanceRequestValidator(),
                                      identifierService: IdentifierService(),
                                      linkedDomainService: LinkedDomainService())
        
        do {
            // Act
            let response = try IssuanceResponseContainer(from: contract, contractUri: expectedUrl)
            let _ = try await service.send(response: response)
            XCTFail()
        } catch {
            // Assert
            XCTAssert(MockIssuanceResponseFormatter.wasFormatCalled)
            XCTAssertFalse(MockIssuanceApiCalls.wasPostResponseCalled)
            XCTAssert(error is MockIssuanceResponseFormatterError)
        }
    }
    
    func testSendCompletionResponse() async throws {
        // Arrange
        let response = IssuanceCompletionResponse(wasSuccessful: false,
                                                  withState: "testState",
                                                  andDetails: IssuanceCompletionErrorDetails.issuanceServiceError)
        
        do {
            // Act
            let _ = try await service.sendCompletionResponse(for: response, to: "test.com")
            XCTFail()
        } catch {
            // Assert
            XCTAssert(MockIssuanceApiCalls.wasPostCompletionResponseCalled)
            XCTAssert(error is MockIssuanceNetworkingError)
        }
    }
}
