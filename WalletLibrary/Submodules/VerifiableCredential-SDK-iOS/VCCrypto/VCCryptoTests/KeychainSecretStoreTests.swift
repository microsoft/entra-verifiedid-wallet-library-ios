/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation


import XCTest
@testable import VCCrypto

class KeychainSecretStoreTests: XCTestCase {
    
    func testSaveAndRetrieve() throws {
        var secret = Data(repeating: 1, count: 32)
        let secretCopy = Data(secret)
        let store = KeychainSecretStore()
        let secretId = UUID()
        try store.saveSecret(id: secretId, itemTypeCode: "ABCD", value: &secret)
        let retreivedSecret = try store.getSecret(id: secretId, itemTypeCode: "ABCD", accessGroup: nil)
        XCTAssertEqual(secretCopy, retreivedSecret)
    }
    
    func testSaveAndRetrieveAsDifferentType() throws {
        let secretId : UUID = UUID()
        let store = KeychainSecretStore()
        var value = Data(repeating: 1, count: 32)
        try store.saveSecret(id: secretId, itemTypeCode: "ABCD", value: &value)
        do {
            let _ = try store.getSecret(id: secretId, itemTypeCode: "AAAA", accessGroup: nil)
            XCTAssertTrue(false)
        } catch SecretStoringError.itemNotFound {
            // We expect an exception for this case.
        }
    }
}
