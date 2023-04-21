/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IdentifierDocumentServiceEndpointDescriptor: Codable, Equatable {
    let id: String?
    let type: String?
    let serviceEndpoint: IdentifierDocumentServiceEndpoint
    
    init(id: String?, type: String?, serviceEndpoint: IdentifierDocumentServiceEndpoint) {
        self.id = id
        self.type = type
        self.serviceEndpoint = serviceEndpoint
    }
}
