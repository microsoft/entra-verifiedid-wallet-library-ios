/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol that defines a Mapper used to map one object to another.
 */
protocol Mapping {
    func map<T: Mappable>(_ object: T) throws -> T.T
}
