/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

struct ContractDecoder: Decoding {
    typealias Decodable = SignedContract
    
    private let decoder = JSONDecoder()
    
    func decode(data: Data) throws -> SignedContract {
        
        let response = try decoder.decode(ContractServiceResponse.self, from: data)
        
        guard let token = SignedContract(from: response.token) else {
            throw DecodingError.unableToDecodeToken
        }
        
        return token
    }
}
