/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCToken
import VCCrypto

@testable import VCEntities

class PresentationResponseFormatterTests: XCTestCase {
    
    var formatter: PresentationResponseFormatter!
    var request: PresentationRequest!
    var mockResponse: PresentationResponseContainer!
    var mockIdentifier: Identifier!
    let expectedContractUrl = "https://portableidentitycards.azure-api.net/v1.0/9c59be8b-bd18-45d9-b9d9-082bc07c094f/portableIdentities/contracts/AIEngineerCert"
    let expectedCredentialType = "test435"
    
    override func setUpWithError() throws {
        let signer = MockTokenSigner(x: "x", y: "y")
        self.formatter = PresentationResponseFormatter(signer: signer)
        
        let encodedRequest = TestData.presentationRequest.rawValue.data(using: .utf8)!
        self.request = PresentationRequest(from: JwsToken(from: encodedRequest)!, linkedDomainResult: .linkedDomainVerified(domainUrl: "test.com"))
        
        self.mockResponse = try PresentationResponseContainer(from: self.request)
        
        let keyManagementOperations = KeyManagementOperations(secretStore: SecretStoreMock(), sdkConfiguration: VCSDKConfiguration.sharedInstance)
        let key = try keyManagementOperations.generateKey()
        
        let keyContainer = KeyContainer(keyReference: key, keyId: "keyId")
        self.mockIdentifier = Identifier(longFormDid: "longFormDid", didDocumentKeys: [keyContainer], updateKey: keyContainer, recoveryKey: keyContainer, alias: "testAlias")
    }
    
    func testFormatToken() throws {
        let vc = VerifiableCredential(from: TestData.verifiableCredential.rawValue)!
        self.mockResponse.requestVCMap.append(RequestedVerifiableCredentialMapping(id: expectedCredentialType,
                                                                                   verifiableCredential: vc))
        
        let formattedResponse = try formatter.format(response: self.mockResponse, usingIdentifier: self.mockIdentifier)
        
        XCTAssertNotNil(formattedResponse.idToken.content.exp)
        XCTAssertNotNil(formattedResponse.idToken.content.iat)
        XCTAssertEqual(formattedResponse.idToken.content.subject, self.mockIdentifier.longFormDid)
        XCTAssertEqual(formattedResponse.idToken.content.audience, self.mockResponse.audienceDid)
        XCTAssert(MockTokenSigner.wasSignCalled)
        XCTAssert(MockTokenSigner.wasGetPublicJwkCalled)
    }
    
    func testFormatTokenNoVcs() throws {

        let formattedResponse = try formatter.format(response: self.mockResponse, usingIdentifier: self.mockIdentifier)
        XCTAssertEqual(formattedResponse.idToken.content.subject, self.mockIdentifier.longFormDid)
        XCTAssertNotNil(formattedResponse.idToken.content.exp)
        XCTAssertNotNil(formattedResponse.idToken.content.iat)
        XCTAssertEqual(formattedResponse.idToken.content.audience, self.mockResponse.audienceDid)
        XCTAssert(MockTokenSigner.wasSignCalled)
        XCTAssert(MockTokenSigner.wasGetPublicJwkCalled)
    }
}
