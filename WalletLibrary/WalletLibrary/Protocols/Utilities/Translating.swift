/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Protocol that defines a Translator used to translate one object to another.
protocol Translating {
    func translate<T: Translateable>(_ object: T) throws -> T.T
}
