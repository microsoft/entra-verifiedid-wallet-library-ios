/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

struct DIDDocumentDecoder: Decoding {
    
    private let decoder = JSONDecoder()
    
    func decode(data: Data) throws -> IdentifierDocument {
        return try decoder.decode(DiscoveryServiceResponse.self, from: data).didDocument
    }
}
