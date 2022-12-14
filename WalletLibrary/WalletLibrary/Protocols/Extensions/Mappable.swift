/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors pertaining to Mapping one data model to another using the Mappable protocol.
 */
enum MappingError: Error, Equatable {
    case PropertyNotPresent(property: String, in: String)
    case InvalidProperty(property: String, in: String)
}

/**
 * Translate the object that conforms to Mappable to object T.
 * This pattern is very similar to the JSONEncoder pattern, and will be tied to a Mapper.
 */
protocol Mappable {
    associatedtype T
    
    /// Translates the object that conforms to the protocol to another object.
    func map(using mapper: Mapping) throws -> T
}

extension Mappable {
    
    func getRequiredProperty<U>(property: U?, propertyName: String) throws -> U {
        
        guard let requiredProperty = property else {
            throw MappingError.PropertyNotPresent(property: propertyName, in: String(describing: Self.self))
        }
        
        return requiredProperty
    }
}
