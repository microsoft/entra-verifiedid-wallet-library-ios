/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCServices

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
                                  linkedDomainService: LinkedDomainService(),
                                  pairwiseService: PairwiseService())
        
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
        let service = IssuanceService()
        XCTAssertNotNil(service.formatter)
        XCTAssertNotNil(service.apiCalls)
    }

    func testGetRequest() throws {
        let expec = self.expectation(description: "Fire")
        service.getRequest(usingUrl: expectedUrl).done {
            request in
            print(request)
            XCTFail()
            expec.fulfill()
        }.catch { error in
            XCTAssert(MockIssuanceApiCalls.wasGetCalled)
            XCTAssert(error is MockIssuanceNetworkingError)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 5)
    }
    
    func testSendResponse() throws {
        let expec = self.expectation(description: "Fire")
        let response = try IssuanceResponseContainer(from: contract, contractUri: expectedUrl)
        service.send(response: response).done {
            response in
            print(response)
            XCTFail()
            expec.fulfill()
        }.catch { error in
            print(error)
            XCTAssert(MockIssuanceResponseFormatter.wasFormatCalled)
            XCTAssert(MockIssuanceApiCalls.wasPostResponseCalled)
            XCTAssert(error is MockIssuanceNetworkingError)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 20)
    }
    
    func testSendResponseFailedToFormat() throws {
        let expec = self.expectation(description: "Fire")
        
        let formatter = MockIssuanceResponseFormatter(shouldSucceed: false)
        let service = IssuanceService(formatter: formatter,
                                      apiCalls: MockIssuanceApiCalls(),
                                      discoveryApiCalls: MockDiscoveryApiCalls(),
                                      requestValidator: MockIssuanceRequestValidator(),
                                      identifierService: IdentifierService(),
                                      linkedDomainService: LinkedDomainService(),
                                      pairwiseService: PairwiseService())
        
        let response = try IssuanceResponseContainer(from: contract, contractUri: expectedUrl)
        service.send(response: response).done {
            response in
            print(response)
            XCTFail()
            expec.fulfill()
        }.catch { error in
            XCTAssert(MockIssuanceResponseFormatter.wasFormatCalled)
            XCTAssertFalse(MockIssuanceApiCalls.wasPostResponseCalled)
            XCTAssert(error is MockIssuanceResponseFormatterError)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 20)
    }
    
    func testSendCompletionResponse() throws {
        let expec = self.expectation(description: "Fire")
        let response = IssuanceCompletionResponse(wasSuccessful: false,
                                                  withState: "testState",
                                                  andDetails: IssuanceCompletionErrorDetails.issuanceServiceError)
        service.sendCompletionResponse(for: response, to: "test.com").done {
            response in
            XCTFail()
            expec.fulfill()
        }.catch { error in
            print(error)
            XCTAssert(MockIssuanceApiCalls.wasPostCompletionResponseCalled)
            XCTAssert(error is MockIssuanceNetworkingError)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 20)
    }
}
