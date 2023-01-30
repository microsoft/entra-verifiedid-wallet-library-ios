/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utility Class used to handle data model mapping.
 */
struct Mapper: Mapping {
    
    /// Map one object to another.
    func map<T: Mappable>(_ object: T) throws -> T.T {
        return try object.map(using: self)
    }
}
