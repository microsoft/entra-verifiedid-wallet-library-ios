/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors pertaining to translating one data model to another using the Translateable protocol.
 */
enum TranslationError<T>: Error {
    case PropertyNotPresent(property: String, in: T.Type)
    case InvalidProperty(property: String, in: T.Type)
}

/**
 * Translate the object that conforms to Translateable to object T.
 * This pattern is very similar to the JSONEncoder pattern, and will be tied to a Translator.
 */
protocol Translateable {
    associatedtype T
    
    /// Translates the object that conforms to the protocol to another object.
    func translate(using translator: Translating) throws -> T
}

extension Translateable {
    
    func getRequiredProperty<U>(property: U?, propertyName: String) throws -> U {
        
        guard let requiredProperty = property else {
            throw TranslationError.PropertyNotPresent(property: propertyName, in: T.self)
        }
        
        return requiredProperty
    }
}
