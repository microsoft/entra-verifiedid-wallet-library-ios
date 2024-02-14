/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utility Class used to handle data model mapping.
 */
struct Mapper: Mapping 
{
    /// Map one object to another with mapping definition on Source object.
    func map<T: Mappable>(_ object: T) throws -> T.T 
    {
        return try object.map(using: self)
    }
    
    /// Map one object to another with mapping definition on Target object.
    func map<Target:MappableTarget>(_ object: Target.Source, type: Target.Type) throws -> Target
    {
        return try Target.map(object, using: self)
    }
}
