/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

public struct PresentationRequestDecoder: Decoding {
    
    public func decode(data: Data) throws -> PresentationRequestToken {
        
        guard let token = PresentationRequestToken(from: data) else {
            throw DecodingError.unableToDecodeToken
        }
        
        return token
    }
}
