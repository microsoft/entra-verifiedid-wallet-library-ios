/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IdentifierDocument: Codable, Equatable, IdentifierMetadata {
    let id: String
    let service: [IdentifierDocumentServiceEndpointDescriptor]?
    let verificationMethod: [IdentifierDocumentPublicKey]?
    let authentication: [String]
    
    init(service: [IdentifierDocumentServiceEndpointDescriptor]?,
                verificationMethod: [IdentifierDocumentPublicKey]?,
                authentication: [String],
                id: String) {
        self.service = service
        self.verificationMethod = verificationMethod
        self.authentication = authentication
        self.id = id
    }
}
