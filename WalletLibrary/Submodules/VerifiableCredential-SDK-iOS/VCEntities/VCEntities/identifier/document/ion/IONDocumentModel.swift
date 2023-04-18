/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

struct IONDocumentModel: Codable {
    let publicKeys: [IdentifierDocumentPublicKey]
    let services: [IdentifierDocumentServiceEndpoint]?
    
    init(fromJwks jwks: [ECPublicJwk], andServiceEndpoints services: [IdentifierDocumentServiceEndpoint]) {
        var keys: [IdentifierDocumentPublicKey] = []
        for jwk in jwks {
            keys.append(IdentifierDocumentPublicKey(fromJwk: jwk))
        }
        self.publicKeys = keys
        self.services = services
    }
}
