/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct PresentationRequestDecoder: Decoding {
    
    func decode(data: Data) throws -> PresentationRequestToken {
        
        guard let token = PresentationRequestToken(from: data) else {
            throw DecodingError.unableToDecodeToken
        }
        
        return token
    }
}
