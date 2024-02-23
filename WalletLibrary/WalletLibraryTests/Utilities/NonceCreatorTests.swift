/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class NonceCreatorTests: XCTestCase 
{
    
    let nonceCreator = NonceCreator()
    
    func testCreateNonce_WithValidDID_CreatesNonce() async throws 
    {
        // Arrange
        let did = "validDID"
        let expectedResult = "TmDv4cykZTDgsb9-owZmsYw82RVlU72LLm0o1Wp8RbJEge4mDMDe4eJH8s3nq8P5NMm7B_TLnk5xAAR3vr3ubA"
        
        // Act
        let nonce = nonceCreator.createNonce(fromIdentifier: did)
        
        // Assert
        XCTAssertNotNil(nonce)
        let splitNonce = nonce?.split(separator: ".")
        XCTAssertEqual(splitNonce?.count, 2)
        XCTAssertEqual(String(splitNonce![1]), expectedResult)
    }
}
