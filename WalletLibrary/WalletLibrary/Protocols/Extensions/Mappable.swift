/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors pertaining to mapping one data model to another using the Mappable protocol.
 */
enum MappingError: Error, Equatable {
    case PropertyNotPresent(property: String, in: String)
    case InvalidProperty(property: String, in: String)
}

/**
 * Map the object that conforms to Mappable to object T.
 */
protocol Mappable {
    associatedtype T
    
    /// Map the object that conforms to the protocol to another object.
    func map(using mapper: Mapping) throws -> T
}

extension Mappable {
    
    /// Helper method to convert an optional property to a required property, else throw an error.
    func getRequiredProperty<U>(property: U?, propertyName: String) throws -> U {
        
        guard let requiredProperty = property else {
            throw MappingError.PropertyNotPresent(property: propertyName, in: String(describing: Self.self))
        }
        
        return requiredProperty
    }
}

extension Decodable {
    
    /// Helper method to convert an optional property to a required property, else throw an error.
    static func getRequiredProperty<U>(property: U?, propertyName: String) throws -> U {
        
        guard let requiredProperty = property else {
            throw MappingError.PropertyNotPresent(property: propertyName, in: String(describing: Self.self))
        }
        
        return requiredProperty
    }
}
