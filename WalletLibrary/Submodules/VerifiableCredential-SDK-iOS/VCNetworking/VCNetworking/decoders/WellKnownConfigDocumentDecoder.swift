/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct WellKnownConfigDocumentDecoder: Decoding {
    typealias Decodable = WellKnownConfigDocument
    
    private let decoder = JSONDecoder()
    
    func decode(data: Data) throws -> WellKnownConfigDocument {
        return try decoder.decode(WellKnownConfigDocument.self, from: data)
    }
}
