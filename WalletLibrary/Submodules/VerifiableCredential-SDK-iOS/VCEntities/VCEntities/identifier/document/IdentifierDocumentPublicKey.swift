/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IdentifierDocumentPublicKey: Codable, Equatable {
    let id: String?
    let type: String
    let controller: String?
    let publicKeyJwk: PublicJWK
    let purposes: [String]?
    
    init(id: String?,
                type: String,
                controller: String?,
                publicKeyJwk: PublicJWK,
                purposes: [String]?) {
        self.id = id
        self.type = type
        self.controller = controller
        self.publicKeyJwk = publicKeyJwk
        self.purposes = purposes
    }
    
    init(fromJwk key: PublicJWK) {
        self.init(id: key.keyId, type: VCEntitiesConstants.SUPPORTED_PUBLICKEY_TYPE, controller: nil, publicKeyJwk: key, purposes: [VCEntitiesConstants.PUBLICKEY_AUTHENTICATION_PURPOSE_V1])
    }

    func matches(_ keyIdentifier: DIDVerificationMethodIdentifier) -> Bool {
        let controllerMatches = controller == nil || controller == keyIdentifier.did
        let identifierMatches = id == keyIdentifier.absoluteId || id == keyIdentifier.relativeId
        return controllerMatches && identifierMatches
    }
}
