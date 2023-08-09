/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
