/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Presentation Exchange Pattern used to match an input string with pattern.
 */
struct PresentationExchangePattern {
    
    private let regex: NSRegularExpression
    
    init?(from pattern: String) {

        guard let sanitizedPattern = pattern.split(separator: "/").first,
              let regex = try? NSRegularExpression(pattern: String(sanitizedPattern), options: [.caseInsensitive]) else {
            return nil
        }
        
        self.regex = regex
    }
    
    func matches(in input: String) -> Bool {
        let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
        return matches.count > 0
    }
}
