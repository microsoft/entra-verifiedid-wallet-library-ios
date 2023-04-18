/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import Foundation

@testable import VCCrypto

class PbkdfTests : XCTestCase {

    func testKeyDeriviation() throws {

        // Setup, c.f. https://datatracker.ietf.org/doc/html/rfc7517#appendix-C.2
        let password = "Thus from my lips, by yours, my sin is purged."
        let p2s: [UInt8] = [217, 96, 147, 112, 150, 117, 70, 247, 127, 8, 155, 137, 174, 42, 80, 215]
        let algorithmName = "PBES2-HS256+A128KW"
        let expected: [UInt8] = [110, 171, 169, 92, 129, 92, 109, 117, 233, 242, 116, 233, 170, 14, 24, 75]

        // Generate the key
        let pbkdf = Pbkdf()
        let derived = try pbkdf.derive(from: password, withSaltInput: Data(p2s), forAlgorithm: algorithmName, rounds: 4096)
        
        // Validate
        var data = Data()
        try (derived as! Secret).withUnsafeBytes { (derivedPtr) in
            data.append(derivedPtr.bindMemory(to: UInt8.self))
        }
        XCTAssertEqual(Data(expected), data)
    }
}

