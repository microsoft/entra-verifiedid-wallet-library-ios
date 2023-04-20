/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct IdentifierDocument: Codable, Equatable {
    public let id: String
    public let service: [IdentifierDocumentServiceEndpointDescriptor]?
    public let verificationMethod: [IdentifierDocumentPublicKey]?
    public let authentication: [String]
    
    public init(service: [IdentifierDocumentServiceEndpointDescriptor]?,
                verificationMethod: [IdentifierDocumentPublicKey]?,
                authentication: [String],
                id: String) {
        self.service = service
        self.verificationMethod = verificationMethod
        self.authentication = authentication
        self.id = id
    }
}
