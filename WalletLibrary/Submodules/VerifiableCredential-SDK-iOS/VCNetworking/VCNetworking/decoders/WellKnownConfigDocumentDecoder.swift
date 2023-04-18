/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

public struct WellKnownConfigDocumentDecoder: Decoding {
    typealias Decodable = WellKnownConfigDocument
    
    let decoder = JSONDecoder()
    
    public func decode(data: Data) throws -> WellKnownConfigDocument {
        return try decoder.decode(WellKnownConfigDocument.self, from: data)
    }
}
