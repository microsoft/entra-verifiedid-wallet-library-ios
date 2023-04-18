/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCServices

class ExchangeServiceTests: XCTestCase {
    
    var service: ExchangeService!
    var request: ExchangeRequestContainer!
    var mockVerifiableCredential: VerifiableCredential!
    let expectedUrl = "https://test3523.com"
    var mockIdentifier: Identifier!
    var verifiableCredential: VerifiableCredential!
    let identifierDB = IdentifierDatabase()

    override func setUpWithError() throws {
        let formatter = MockExchangeRequestFormatter(shouldSucceed: true)
        service = ExchangeService(formatter: formatter, apiCalls: MockExchangeApiCalls())
        
        let keyContainer = KeyContainer(keyReference: MockVCCryptoSecret(), keyId: "keyId234")
        self.mockIdentifier = Identifier(longFormDid: "longform", didDocumentKeys: [keyContainer], updateKey: keyContainer, recoveryKey: keyContainer, alias: "testAlias")
        
        try identifierDB.saveIdentifier(identifier: mockIdentifier)
        
       mockVerifiableCredential = VerifiableCredential(from: TestData.verifiableCredential.rawValue)!
        
        MockIssuanceResponseFormatter.wasFormatCalled = false
        MockExchangeApiCalls.wasPostCalled = false
    }
    
    override func tearDownWithError() throws {
        try CoreDataManager.sharedInstance.deleteAllIdentifiers()
    }
    
    func testSendResponse() throws {
        let expec = self.expectation(description: "Fire")
        request = try ExchangeRequestContainer(exchangeableVerifiableCredential: mockVerifiableCredential, newOwnerDid: "testNewOwnerDid", currentOwnerIdentifier: mockIdentifier)
        service.send(request: request).done {
            response in
            print(response)
            XCTFail()
            expec.fulfill()
        }.catch { error in
            print(error)
            XCTAssert(MockExchangeRequestFormatter.wasFormatCalled)
            XCTAssert(MockExchangeApiCalls.wasPostCalled)
            XCTAssert(error is MockExchangeNetworkingError)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 20)
    }
}
