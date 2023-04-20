/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

struct ExchangeRequestEncoder: Encoding {
    
    func encode(value: ExchangeRequest) throws -> Data {
        
        guard let encodedToken = try value.serialize().data(using: .ascii) else {
            throw NetworkingError.unableToParseString
        }
        
        return encodedToken
    }
}
