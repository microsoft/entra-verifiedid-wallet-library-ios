/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCEntities

class ExchangeRequestContainerTests: XCTestCase {
    
    var mockIdentifier: Identifier!
    
    override func setUpWithError() throws {
        let mockCryptoSecret = MockCryptoSecret(id: UUID())
        let mockKeyContainer = KeyContainer(keyReference: mockCryptoSecret, keyId: "testKeyId")
        mockIdentifier =  Identifier(longFormDid: "testDid", didDocumentKeys: [mockKeyContainer], updateKey: mockKeyContainer, recoveryKey: mockKeyContainer, alias: "testAlias")
    }

    func testSuccessfulInit() throws {
        let validVc = VerifiableCredential(from: TestData.verifiableCredential.rawValue)!
        do {
            let actualRequest = try ExchangeRequestContainer(exchangeableVerifiableCredential: validVc,
                                                             newOwnerDid: "testNewDid",
                                                             currentOwnerIdentifier: mockIdentifier)
            XCTAssertEqual(actualRequest.audience, validVc.content.vc?.exchangeService?.id)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    // VC does not have exchangeService property, so should fail.
    func testInitThrowsError() throws {
        let invalidVc = VerifiableCredential(from: TestData.pairwiseVerifiableCredential.rawValue)!
        do {
            let actualRequest = try ExchangeRequestContainer(exchangeableVerifiableCredential: invalidVc,
                                                             newOwnerDid: "testNewDid",
                                                             currentOwnerIdentifier: mockIdentifier)
            print(actualRequest)
            XCTFail()
        } catch {
            XCTAssertEqual(error as! ExchangeRequestError, ExchangeRequestError.noAudienceFound)
        }
    }
}
