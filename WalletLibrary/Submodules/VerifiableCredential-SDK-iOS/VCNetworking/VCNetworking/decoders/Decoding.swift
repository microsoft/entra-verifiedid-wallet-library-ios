/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

enum DecodingError: Error {
    case unableToDecodeToken
}

protocol Decoding {
    associatedtype ResponseBody
    
    func decode(data: Data) throws -> ResponseBody
}
