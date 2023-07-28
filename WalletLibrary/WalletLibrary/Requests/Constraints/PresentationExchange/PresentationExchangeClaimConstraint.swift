/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Presentation Exchange Pattern used to match an input string with pattern.
struct PresentationExchangeFieldConstraint: VerifiedIdConstraint
{
    private let field: PresentationExchangeField
    
    init(field: PresentationExchangeField)
    {
        self.field = field
    }
    
    func doesMatch(verifiedId: VerifiedId) -> Bool {
        
        guard let verifiableCredential = verifiedId as? VCVerifiedId else
        {
            return false
        }
        
        guard let paths = field.path else
        {
            return false
        }
        
        do {
            let encodedContent = try JSONEncoder().encode(verifiableCredential.raw.content)
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: encodedContent) as? [String: Any] else
            {
                return false
            }
            
            for path in paths
            {
                let value = getValue(from: jsonObject, with: path)
                if let expectedValue = value as? String
                {
                    return doesFilterMatch(expectedValue: expectedValue)
                }
            }
            
        } catch {
            return false
        }
        
        return false
    }
    
    func matches(verifiedId: VerifiedId) throws { }
    
    private func doesFilterMatch(expectedValue: String) -> Bool
    {
        guard let patternStr = field.filter?.pattern?.pattern,
              let pattern = PresentationExchangePattern(from: patternStr) else
        {
            return false
        }
        
        return pattern.matches(in: expectedValue)
    }
    
    func getValue(from jsonObject: [String: Any], with path: String) -> Any? {
        
        var sanitizedPath = path
        _ = sanitizedPath.removeFirst()
        let keys = sanitizedPath.split(separator: ".").map(String.init)
        
        var currentValue: Any? = jsonObject
        
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
