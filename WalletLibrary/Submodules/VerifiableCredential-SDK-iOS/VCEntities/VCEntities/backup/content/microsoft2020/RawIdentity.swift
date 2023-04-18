/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
#if canImport(VCToken)
    import VCToken
#endif
#if canImport(VCCrypto)
    import VCCrypto
#endif

enum RawIdentityError: Error {
    case signingKeyNotFound
    case recoveryKeyNotFound
    case updateKeyNotFound
    case privateKeyNotFound(keyId: String, accessGroup: String?)
    case keyIdNotFound
}

struct RawIdentity: Codable {
    var id: String
    var name: String
    var keys: [JWK]?
    var recoveryKey: String
    var updateKey: String

    init(identifier: Identifier) throws {
        
        self.id = identifier.did
        self.name = identifier.alias
        self.recoveryKey = identifier.recoveryKey.keyId
        self.updateKey = identifier.updateKey.keyId
        self.keys = nil

        var keys = try identifier.didDocumentKeys.map(jwkFromKeyContainer)
        try keys.append(jwkFromKeyContainer(identifier.recoveryKey))
        try keys.append(jwkFromKeyContainer(identifier.updateKey))
        self.keys = keys
    }
    
    func asIdentifier() throws -> Identifier {
        // Get out the keys
        guard let keys = self.keys else {
            throw RawIdentityError.signingKeyNotFound
        }
        guard let recoveryJwk = keys.first(where: {$0.keyId == self.recoveryKey}) else {
            throw RawIdentityError.recoveryKeyNotFound
        }
        guard let updateJwk = keys.first(where: {$0.keyId == self.updateKey}) else {
            throw RawIdentityError.updateKeyNotFound
        }
        let set = Set([self.recoveryKey, self.updateKey])
        guard let signingJwk = keys.first(where: {!set.contains($0.keyId!)}) else {
            throw RawIdentityError.signingKeyNotFound
        }

        // Convert
        let recoveryKeyContainer = try keyContainerFromJwk(recoveryJwk)
        let updateKeyContainer = try keyContainerFromJwk(updateJwk)
        let signingKeyContainer = try keyContainerFromJwk(signingJwk)
        
        // Wrap up and return
        return Identifier(longFormDid: self.id,
                          didDocumentKeys: [signingKeyContainer],
                          updateKey: updateKeyContainer,
                          recoveryKey: recoveryKeyContainer,
                          alias: self.name)
    }
    
    func jwkFromKeyContainer(_ keyContainer: KeyContainer) throws -> JWK {

        // Get out the private and public components of the key (pair)
        let secret = keyContainer.keyReference
        let (privateKey, publicKey) = try Secp256k1().createKeyPair(forSecret: secret)
        if privateKey.value.isEmpty {
            throw RawIdentityError.privateKeyNotFound(keyId: secret.id.uuidString,
                                                      accessGroup: secret.accessGroup)
        }
        
        // Wrap them up in a JSON Web Key
        return JWK(keyType: "EC",
                   keyId: keyContainer.keyId,
                   curve: "secp256k1",
                   use: "sig",
                   x: publicKey.x,
                   y: publicKey.y,
                   d: privateKey.value)
    }
    
    func keyContainerFromJwk(_ jwk: JWK) throws -> KeyContainer {

        // Get out the ID and the key data
        guard let keyId = jwk.keyId else {
            throw RawIdentityError.keyIdNotFound
        }
        guard let privateKeyData = jwk.d,
              !privateKeyData.isEmpty else {
            throw RawIdentityError.privateKeyNotFound(keyId: keyId, accessGroup: nil)
        }

        // Wrap it all up
        let privateKey = EphemeralSecret(with: privateKeyData,
                                         id: UUID(),
                                         accessGroup: VCSDKConfiguration.sharedInstance.accessGroupIdentifier)
        return KeyContainer(keyReference: privateKey, keyId: keyId)
    }
}
