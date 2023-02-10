/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockMapper: Mapping {
    
    let callback: ((Any) throws -> (Any?))?
    
    init(callback: ((Any) throws -> (Any?))? = nil) {
        self.callback = callback
    }
    
    /// Map one object to another.
    func map<T: Mappable>(_ object: T) throws -> T.T {
        
        if let callback = callback {
            let result = try callback(object)
            if let result = result as? T.T {
                return result
            }
        }
        
        return try object.map(using: self)
    }
}
