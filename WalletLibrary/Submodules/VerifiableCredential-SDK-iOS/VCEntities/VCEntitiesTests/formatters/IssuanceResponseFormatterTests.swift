/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IssuanceResponseFormatterTests: XCTestCase {
    
    var formatter: IssuanceResponseFormatter!
    var contract: Contract!
    var mockResponse: IssuanceResponseContainer!
    var mockIdentifier: Identifier!
    let expectedContractUrl = "https://portableidentitycards.azure-api.net/v1.0/9c59be8b-bd18-45d9-b9d9-082bc07c094f/portableIdentities/contracts/AIEngineerCert"
    
    override func setUpWithError() throws
    {
        self.formatter = IssuanceResponseFormatter(logger: WalletLibraryLogger())
        
        let encodedContract = TestData.aiContract.rawValue.data(using: .utf8)!
        self.contract = try JSONDecoder().decode(Contract.self, from: encodedContract)
        
        try self.mockResponse = IssuanceResponseContainer(from: self.contract, contractUri: self.expectedContractUrl)
        
        let keyManagementOperation = KeyManagementOperations(secretStore: SecretStoreMock(), sdkConfiguration: VCSDKConfiguration.sharedInstance)
        let key = try keyManagementOperation.generateKey()
        
        let keyContainer = KeyContainer(keyReference: key, keyId: "keyId")
        self.mockIdentifier = Identifier(longFormDid: "longFormDid", didDocumentKeys: [keyContainer], updateKey: keyContainer, recoveryKey: keyContainer, alias: "testAlias")
    }
    
    func testFormat_withHolder_ReturnsToken() throws
    {
        // Arrange
        let mockSignature = "mockSignature".data(using: .utf8)
        let identifier = MockHolderIdentifier(expectedSignature: mockSignature, id: "mockId")
        
        // Act
        let formattedToken = try formatter.format(response: mockResponse,
                                                  identifier: identifier)
        
        // Assert
        XCTAssertEqual(formattedToken.content.did, identifier.id)
        XCTAssertEqual(formattedToken.content.contract, self.mockResponse.contractUri)
        XCTAssertEqual(formattedToken.content.audience, self.mockResponse.audienceUrl)
        XCTAssertEqual(formattedToken.signature, mockSignature)
    }
    
}
