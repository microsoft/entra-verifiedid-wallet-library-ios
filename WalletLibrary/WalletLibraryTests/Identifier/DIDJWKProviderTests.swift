/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class DIDJWKProviderTests: XCTestCase
{
    func testCreateDID_WithValidInput_ReturnsDIDJWK() throws
    {
        // Arrange
        let expectedXValue = "acbIQiuMs3i8_uszEjJ2tpTtRM4EU3yz91PH6CdH2V0"
        let expectedYValue = "_KcyLj9vWMptnmKtm46GqDz8wf74I5LKgrl2GzH3nSE"
        let publicKey = ES256PublicKey(x: Data(base64URLEncoded: expectedXValue)!,
                                       y: Data(base64URLEncoded: expectedYValue)!)!
        let provider = DIDJWKProvider()
        
        // Act
        var result = try provider.createDID(ecPublicKey: publicKey)
        
        // Assert
        XCTAssertEqual(result.prefix(8), "did:jwk:")
        
        result.removeFirst(8)
        let encodedResult = Data(base64URLEncoded: result)!
        let parsedOutResult = (try JSONSerialization.jsonObject(with: encodedResult)) as! [String: String]
        
        XCTAssertEqual(parsedOutResult["crv"], "P-256")
        XCTAssertEqual(parsedOutResult["kty"], "EC")
        XCTAssertEqual(parsedOutResult["x"], expectedXValue)
        XCTAssertEqual(parsedOutResult["y"], expectedYValue)
    }
}
