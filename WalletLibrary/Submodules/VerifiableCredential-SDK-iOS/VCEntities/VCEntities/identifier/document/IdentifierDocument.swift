/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IdentifierDocument: Codable, Equatable {
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
    
    func getJWK(id: String) -> JWK?
    {
        guard let publicKeys = verificationMethod else
        {
            return nil
        }
        
        for publicKey in publicKeys
        {
            if publicKey.id == id
            {
                return publicKey.publicKeyJwk.toJWK()
            }
        }
        
        return nil
    }
}
