/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol that defines a Mapper used to map one object to another.
 */
protocol Mapping {
    func map<T: Mappable>(_ object: T) throws -> T.T
    
    func map<Target:MappableTarget>(_ object: Target.Source, type: Target.Type) throws -> Target
}

protocol MappableTarget
{
    associatedtype Source
    
    static func map(_ object: Source, using mapper: Mapping) throws -> Self
}

extension MappableTarget
{
    static func validateValueExists<T>(_ key: String, in json: [String: Any]) throws -> T
    {
        guard let value = json[key] as? T else
        {
            throw MappingError.PropertyNotPresent(property: key,
                                                  in: String(describing: Self.self))
        }
        
        return value
    }
}
