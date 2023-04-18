/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

import VCCrypto

@testable import VCEntities

class MultihashTests: XCTestCase {

    func testCompute() {
        let multihash = Multihash()
        let testInput = "431fb5d4c9b735ba1a34d0df045118806ae2336f2c"
        let testData = Data(hexString: testInput)
        print(multihash.compute(from: testData).toHexString())
    }
}



