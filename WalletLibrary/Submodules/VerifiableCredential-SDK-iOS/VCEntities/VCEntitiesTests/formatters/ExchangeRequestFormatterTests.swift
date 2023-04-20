/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCCrypto
import VCToken

@testable import VCEntities

class ExchangeRequestFormatterTests: XCTestCase {
    
    var formatter: ExchangeRequestFormatter!
    var mockRequest: ExchangeRequestContainer!
    var mockIdentifier: Identifier!
    var mockValidVc: VerifiableCredential!
    
    let expectedNewOwnerDid: String = "newOwnerDid235"
    let mockOwnerIdentifier = "mockIdentifier"
    let testHeader = Header(type: "testType", algorithm: "testAlg", jsonWebKey: "testWebKey", keyId: "testKid")
    
    override func setUpWithError() throws {
        let signer = MockTokenSigner(x: "x", y: "y")
        formatter = ExchangeRequestFormatter(signer: signer)
        
        let keyManagementOperation = KeyManagementOperations(secretStore: SecretStoreMock(), sdkConfiguration: VCSDKConfiguration.sharedInstance)
        let key = try keyManagementOperation.generateKey()
        
        let vc = VerifiableCredentialDescriptor(context: nil,
                                                type: nil,
                                                credentialSubject: nil,
                                                exchangeService: ServiceDescriptor(id: "testServiceId", type: "testType"))
        let vcClaims = VCClaims(jti: "testJti",
                                iss: "testIssuer",
                                sub: mockOwnerIdentifier,
                                iat: nil,
                                exp: nil,
                                vc: vc)
        
        mockValidVc = VerifiableCredential(headers: testHeader, content: vcClaims, rawValue: "testRawValue")
        
        let keyContainer = KeyContainer(keyReference: key, keyId: "keyId")
        mockIdentifier = Identifier(longFormDid: mockOwnerIdentifier, didDocumentKeys: [keyContainer], updateKey: keyContainer, recoveryKey: keyContainer, alias: "testAlias")
        
        mockRequest = try ExchangeRequestContainer(exchangeableVerifiableCredential: mockValidVc, newOwnerDid: expectedNewOwnerDid, currentOwnerIdentifier: mockIdentifier)
    }
    
    func testExchangeFormatter() throws {
        let actualExchangeRequest = try formatter.format(request: mockRequest)
        XCTAssertEqual(actualExchangeRequest.content.audience, mockRequest.audience)
        XCTAssertEqual(actualExchangeRequest.content.did, mockOwnerIdentifier)
        XCTAssertEqual(actualExchangeRequest.content.exchangeableVc, mockValidVc.rawValue)
        XCTAssertEqual(actualExchangeRequest.content.issuer, VCEntitiesConstants.SELF_ISSUED)
        XCTAssertEqual(actualExchangeRequest.content.recipientDid, expectedNewOwnerDid)
    }
}
