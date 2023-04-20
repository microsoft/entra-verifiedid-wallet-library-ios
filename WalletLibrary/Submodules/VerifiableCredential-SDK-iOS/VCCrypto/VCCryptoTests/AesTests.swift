/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import Foundation

@testable import VCCrypto

class AesTests: XCTestCase {
    
    private var fixture: Aes!
    
    override func setUpWithError() throws {
        self.fixture = Aes()
    }

    /// A sample 'content encryption key' (c.f. rfc3394)
    private let cek = EphemeralSecret(with: Data(hexString: "00112233445566778899AABBCCDDEEFF000102030405060708090A0B0C0D0E0F"))
    
    /// A sample 'key encrypting key'
    private let kek = EphemeralSecret(with: Data(hexString: "000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F"))

    /// The sample CEK wrapped with the KEK
    private let wrapped = Data(hexString: "28C9F404C4B810F4CBCCB35CFB87F8263F5786E2D80ED326CBC7F0E71A99F43BFB988B9B7A02DD21")
        
    func testKeyWrap() throws {
        
        let result = try fixture.wrap(key: cek, with: kek)
        XCTAssertEqual(result, wrapped)
    }
    
    func testKeyUnwrap() throws {
        
        let result = try fixture.unwrap(wrapped: wrapped, using: kek)
        var data = Data()
        try (result as! Secret).withUnsafeBytes{ resultPtr in
            data.append(resultPtr.bindMemory(to: UInt8.self))
        }
        XCTAssertEqual(data, cek.value)
    }
    
    /// c.f. rfc3602
    private let key = EphemeralSecret(with: Data(hexString: "56e47a38c5598974bc46903dba290349"))
    private let iv = Data(hexString: "8ce82eefbea0da3c44699ed7db51b7d9")
    private let plaintext = Data(hexString: "a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf")
    private let ciphertext = Data(hexString: "c30e32ffedc0774e6aff6af0869f71aa0f3af07a9a31a9c684db207eb0ef8e4e35907aa632c3ffdf868bb7b29d3d46ad83ce9f9a102ee99d49a53e87f4c3da55")

    func testAESEncryption() throws {

        let result = try fixture.encrypt(data: plaintext, with: key, iv: iv)
        XCTAssertEqual(result, ciphertext)
    }

    func testAESDecryption() throws {
        
        let result = try fixture.decrypt(data: ciphertext, with: key, iv: iv)
        XCTAssertEqual(result, plaintext)
    }
    
    func testAESNonAlignedInput() throws {

        /// 17 bytes of input
        let plaintext = self.plaintext.prefix(fixture.blockSize+1)
        let encrypted = try fixture.encrypt(data: plaintext, with: key, iv: iv)
        let decrypted = try fixture.decrypt(data: encrypted, with: key, iv: iv)

        /// Validate
        XCTAssertEqual(decrypted, plaintext)
    }
}
