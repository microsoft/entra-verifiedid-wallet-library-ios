/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct IdentifierDocumentServiceEndpointDescriptor: Codable, Equatable {
    let id: String?
    public let type: String?
    public let serviceEndpoint: IdentifierDocumentServiceEndpoint
    
    public init(id: String?, type: String?, serviceEndpoint: IdentifierDocumentServiceEndpoint) {
        self.id = id
        self.type = type
        self.serviceEndpoint = serviceEndpoint
    }
}
