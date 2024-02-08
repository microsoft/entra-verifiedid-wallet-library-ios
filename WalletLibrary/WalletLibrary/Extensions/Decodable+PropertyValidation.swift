/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension to help with validating a required property exists.
 */
extension Decodable
{
    /// Helper method to convert an optional property to a required property, else throw an error.
    static func getRequiredProperty<U>(property: U?, propertyName: String) throws -> U
    {
        guard let requiredProperty = property else {
            throw MappingError.PropertyNotPresent(property: propertyName, in: String(describing: Self.self))
        }
        
        return requiredProperty
    }
}
