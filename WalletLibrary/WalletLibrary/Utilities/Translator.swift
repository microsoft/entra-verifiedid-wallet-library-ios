/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utility Class used to handle data model transformations
 */
struct Translator: Translating {
    
    /// Translate one object into another.
    func translate<T: Translateable>(_ object: T) throws -> T.T {
        return try object.translate(using: self)
    }
}
