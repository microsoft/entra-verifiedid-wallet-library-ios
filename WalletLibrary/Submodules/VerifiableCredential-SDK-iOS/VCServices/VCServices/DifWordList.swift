/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation

public class DifWordList {
    
    let words: [String]
    
    public init?() throws {

        if let path = Bundle(for: Self.self).path(forResource: "difwordlist", ofType: "txt") {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            self.words = content.components(separatedBy: .whitespacesAndNewlines).filter{ !($0.isEmpty) }
        } else {
            return nil
        }
    }

    /// Selects a word at random from the list and returns it
    public func randomWord() -> String {
        let index = arc4random_uniform(UInt32(self.words.count))
        return self.words[Int(index)]
    }
    
    /// Randomly selects a specified number of words from the list
    /// - Parameters:
    ///   - count: The number of words to select
    /// - Returns: An array of words selected at random from the list up to lesser of the specified number or the number of words in the list
    public func randomWords(count:UInt32) -> [String] {

        // Look for an early out
        if count == 0 {
            return [String]()
        }
        if count >= UInt32(self.words.count) {
            // We need to return all the words in the list
            // so we take a copy and randomly shuffle it
            return self.words.shuffled()
        }
        
        var list = [String]()
        var set = Set<String>()
        repeat {
            // Get another word
            let word = self.randomWord()
            
            // Was it already selected?
            if set.contains(word) {
                continue
            }
            
            // Nope
            set.insert(word)
            list.append(word)
        } while (list.count < count)
        return list
    }

    public static func normalize(password:String) -> String {

        var list = [String]()

        // Split the input string along whitespace, etc, and accumulate
        // each non-empty substring
        let components = password.components(separatedBy: .whitespacesAndNewlines)
        components.forEach { component in
            if component.isEmpty {
                return
            }
            list.append(component.lowercased())
        }
        
        return list.joined(separator: " ")
    }
}
