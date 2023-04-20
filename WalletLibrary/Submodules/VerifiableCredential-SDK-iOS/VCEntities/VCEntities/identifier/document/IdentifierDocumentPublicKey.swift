/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct IdentifierDocumentPublicKey: Codable, Equatable {
    let id: String?
    let type: String
    let controller: String?
    let publicKeyJwk: ECPublicJwk
    let purposes: [String]?
    
    public init(id: String?,
                type: String,
                controller: String?,
                publicKeyJwk: ECPublicJwk,
                purposes: [String]?) {
        self.id = id
        self.type = type
        self.controller = controller
        self.publicKeyJwk = publicKeyJwk
        self.purposes = purposes
    }
    
    init(fromJwk key: ECPublicJwk) {
        self.init(id: key.keyId, type: VCEntitiesConstants.SUPPORTED_PUBLICKEY_TYPE, controller: nil, publicKeyJwk: key, purposes: [VCEntitiesConstants.PUBLICKEY_AUTHENTICATION_PURPOSE_V1])
    }
}
