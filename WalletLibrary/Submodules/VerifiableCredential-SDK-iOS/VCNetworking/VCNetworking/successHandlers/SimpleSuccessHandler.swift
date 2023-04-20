/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

class SimpleSuccessHandler: SuccessHandler {
    
    func onSuccess<Decoder: Decoding>(data: Data, decodeWith decoder: Decoder) throws -> Decoder.ResponseBody {
        return try decoder.decode(data: data)
    }
}
