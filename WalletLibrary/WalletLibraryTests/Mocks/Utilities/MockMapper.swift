/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockMapper: Mapping {
    
    let error: Error?
    
    let returnedObject: Any?
    
    init(error: Error? = nil, returnedObject: Any? = nil) {
        self.error = error
        self.returnedObject = returnedObject
    }
    
    /// Map one object to another.
    func map<T: Mappable>(_ object: T) throws -> T.T {
        
        if let error = error {
            throw error
        }
        
        if let returnedObject = returnedObject as? T.T {
            return returnedObject
        }
        
        return try object.map(using: self)
    }
}
