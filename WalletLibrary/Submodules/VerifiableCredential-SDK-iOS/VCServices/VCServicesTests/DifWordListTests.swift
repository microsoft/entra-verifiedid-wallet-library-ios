/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCServices

class DifWordListTests: XCTestCase {
    
    var fixture: DifWordList? = nil
    
    override func setUpWithError() throws {
        self.fixture = try DifWordList()
    }
    
    func testDifWordListRandomSelection() throws {
        
        let count = 12;
        guard let words = fixture?.randomWords(count: UInt32(count)) else {
            XCTFail("Failed to generate a random sequence of words using \(String(describing: fixture))")
            return
        }
        NSLog("Words: %@", words)

        // Validate that the returned list contains the specified number of words
        // with no repetition
        let set = Set(words)
        XCTAssertEqual(set.count, count, "Unexpected number of words in generated password")
    }

    func testDifWordsListUpperBounds() throws {

        // Get all the words from the list
        guard let words1 = fixture?.randomWords(count: UInt32.max) else {
            XCTFail("Failed to generate a random sequence of words using \(String(describing: fixture))")
            return
        }
        
        // Do it again
        guard let words2 = fixture?.randomWords(count: UInt32.max) else {
            XCTFail("Failed to generate a random sequence of words using \(String(describing: fixture))")
            return
        }

        // Ensure that they are not the same
        let separator = " "
        XCTAssertNotEqual(words1.joined(separator: separator), words2.joined(separator: separator))
    }
    
    func testDifWordListLowerBounds() throws {
        
        let zero = 0
        guard let words = fixture?.randomWords(count: UInt32(zero)) else {
            XCTFail("Failed to generate an empty sequence of words using \(String(describing: fixture))")
            return
        }
        XCTAssertEqual(words.count, zero)
    }
}
