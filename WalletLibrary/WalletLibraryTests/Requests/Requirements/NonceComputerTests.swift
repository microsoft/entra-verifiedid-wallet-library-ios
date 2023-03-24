/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class NonceComputerTests: XCTestCase {
    
    func testCreateHash_WithValidDid_ReturnsValidHash() async throws {
        
        // Arrange
        let did = "did:ion:EiBEzgH4PDn194on9Aa4V4EpkN_wqGoRvS6OO_TyrIyowA:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W3siaWQiOiJzaWduX0c4QnpsbjlNSlAiLCJwdWJsaWNLZXlKd2siOnsiYWxnIjoiRVMyNTZLIiwiY3J2Ijoic2VjcDI1NmsxIiwia2V5X29wcyI6WyJ2ZXJpZnkiXSwia2lkIjoic2lnbl9HOEJ6bG45TUpQIiwia3R5IjoiRUMiLCJ1c2UiOiJzaWciLCJ4IjoiZE56TGNRRkZZQnNXbG5LbGdlNXhuaEktZWQyVm1zczZkOXhKMndhdU10USIsInkiOiI2a0gzbmQzWGxnbW1XOEtOcGdRQk16NXVUS0tmTkxuNjVwQVVSZXRWWHFBIn0sInB1cnBvc2VzIjpbImF1dGhlbnRpY2F0aW9uIl0sInR5cGUiOiJFY2RzYVNlY3AyNTZrMVZlcmlmaWNhdGlvbktleTIwMTkifV0sInNlcnZpY2VzIjpbXX19XSwidXBkYXRlQ29tbWl0bWVudCI6IkVpRE5HVzdPTmZoZER4eFZHbUM5Y1FjbzZpN2l5U1pnMkZqZXpJcVRMalNCMmcifSwic3VmZml4RGF0YSI6eyJkZWx0YUhhc2giOiJFaUFKczA1WUIwaUJMQ2p2clNfaUVKYUNaSnpCMlVscXZ5OTlLX3U2WV8yNHp3IiwicmVjb3ZlcnlDb21taXRtZW50IjoiRWlBd21NMDMybkNhc0s5Q1NadXhjdk1vX2hKX1dkWGRXbUZOU1o4cl95dkZSUSJ9fQ"
        let expectedDidHash = "hlL6mzcX5VYWu4bFagCnRXxSpwZLdMmMEhE7VnvqIQvWFQ8LFflO0E2_0vEUgssI0d2FjSZmhvkh32zlVBVj6g"
        
        // Act
        let actualResult = NonceComputer().createNonce(from: did)
        let didHash = String(describing: actualResult!.split(separator: ".")[1])
        
        // Assert
        XCTAssertEqual(didHash, expectedDidHash)
        
    }
}
