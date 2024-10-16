/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct IssuanceServiceResponseDecoder: Decoding {
    
    private let jsonDecoder = JSONDecoder()
    
    func decode(data: Data) throws -> VerifiableCredential {
        let response = try jsonDecoder.decode(IssuanceServiceResponse.self, from: data)
        
        guard let token = VerifiableCredential(from: response.vc) else {
            throw DecodingError.unableToDecodeToken
        }
        
        return token
    }
}
