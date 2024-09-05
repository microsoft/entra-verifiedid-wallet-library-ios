/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension to help with forming a URLEncodedString from a dictionary.
 */
extension Dictionary
{
    func toURLEncodedString() throws -> String
    {
        var parts: [String] = []
        for (key, value) in self
        {
            if let key = key as? String,
               let value = value as? String
            {
                let part = "\(try urlEncode(key))=\(try urlEncode(value))"
                parts.append(part)
            }
        }
        return parts.joined(separator: "&")
    }
    
    private func urlEncode(_ string: String) throws -> String
    {
        // Define the allowed characters according to RFC 3986
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: "$-_.+!*'(),")

        // Perform percent encoding, replacing spaces with `+`
        guard let percentEncodedString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) else
        {
            throw VerifiedIdError(message: "Unable to URL Encode input", code: "encoding_error")
        }
        
        return percentEncodedString
    }
}

/**
 * A Dictionary helper method to get the value defined on a specific path.
 */
extension Dictionary where Key == String, Value == Any {
    
    func getValue(with path: String) -> Any? {
        
        var sanitizedPath = path
        
        if sanitizedPath.starts(with: "$") {
            _ = sanitizedPath.removeFirst()
        }
        
        if sanitizedPath.starts(with: ".") {
            _ = sanitizedPath.removeFirst()
        }
        
        let keys = sanitizedPath.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        var currentValue: Any? = self
        
        if (keys.contains { $0.count == 0 }) {
            return nil
        }
        
        for key in keys {

            if let currentDict = currentValue as? [String: Any],
               let value = currentDict[key] {
                
                currentValue = value
                
            } else if let currentArray = currentValue as? [Any],
                      let index = Int(key),
                      currentArray.indices.contains(index) {
                
                currentValue = currentArray[index]

            } else {
                // Path not found
                return nil
            }
        }
        
        return currentValue
    }
}
