/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

/**
 * Mock Mapper can be used to mock results of a mapping using the mockResults callback.
 * If mockResults callback is not nil, and the result of the call conforms to the T.T protocol,
 * the result of the callback will be returned. Else, object's map function will be used to map like a normal mapper.
 *
 * Using the mockResults callback is helpful when testing the mapping of an object X with recursive mapping.
 * Since unit tests for object X do not need to test the mapping of objects X contains, the mockResults callback
 * can be used to return a mock object or mock error instead.
 */
struct MockMapper: Mapping {
    
    let mockResults: ((Any) throws -> (Any?))?
    
    init(mockResults: ((Any) throws -> (Any?))? = nil) {
        self.mockResults = mockResults
    }
    
    /// Map one object to another.
    func map<T: Mappable>(_ object: T) throws -> T.T {
        
        if let mockResults = mockResults {
            let result = try mockResults(object)
            if let result = result as? T.T {
                return result
            }
        }
        
        return try object.map(using: self)
    }
}
