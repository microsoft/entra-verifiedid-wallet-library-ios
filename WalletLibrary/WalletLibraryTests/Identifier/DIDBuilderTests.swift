/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class DIDBuilderTests: XCTestCase
{
    func testCreateDID_WithInvalidPublicKeyType_ThrowsError() throws
    {
        // Arrange
        let publicKey = Secp256k1PublicKey(x: Data(count: 32), y: Data(count: 32))!
        
        let builder = DIDBuilder()

        // Act / Assert
        XCTAssertThrowsError(try builder.build(from: publicKey, method: "did:jwk")) { error in
            
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "invalid_public_key")
            XCTAssertEqual(identifierError.message, "Invalid Key Type: Secp256k1PublicKey.")
        }
    }
    
    func testCreateDID_WithInvalidMethod_ThrowsError() throws
    {
        // Arrange
        let expectedXValue = "acbIQiuMs3i8_uszEjJ2tpTtRM4EU3yz91PH6CdH2V0"
        let expectedYValue = "_KcyLj9vWMptnmKtm46GqDz8wf74I5LKgrl2GzH3nSE"
        let publicKey = ES256PublicKey(x: Data(base64URLEncoded: expectedXValue)!,
                                       y: Data(base64URLEncoded: expectedYValue)!)!
        
        let builder = DIDBuilder()

        // Act / Assert
        XCTAssertThrowsError(try builder.build(from: publicKey, method: "did:invalid")) { error in
            
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "unsupported_did_method")
            XCTAssertEqual(identifierError.message, "Unsupported DID Method: did:invalid.")
        }
    }
    
    func testCreateDID_WithValidInput_ReturnsDIDJWK() throws
    {
        // Arrange
        let expectedXValue = "acbIQiuMs3i8_uszEjJ2tpTtRM4EU3yz91PH6CdH2V0"
        let expectedYValue = "_KcyLj9vWMptnmKtm46GqDz8wf74I5LKgrl2GzH3nSE"
        let publicKey = ES256PublicKey(x: Data(base64URLEncoded: expectedXValue)!,
                                       y: Data(base64URLEncoded: expectedYValue)!)!
        let builder = DIDBuilder()

        // Act
        var result = try builder.build(from: publicKey, method: "did:jwk")

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
