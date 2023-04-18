/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

protocol IdentifierFormatting {
    func createIonLongFormDid(recoveryKey: ECPublicJwk,
                           updateKey: ECPublicJwk,
                           didDocumentKeys: [ECPublicJwk],
                           serviceEndpoints: [IdentifierDocumentServiceEndpoint]) throws -> String
}

struct IdentifierFormatter: IdentifierFormatting {
    
    private let multihash: Multihash = Multihash()
    private let encoder: JSONEncoder = JSONEncoder()
    
    private static let ionPrefix = "did:ion:"
    private static let ionQueryValue = ":"
    private static let replaceAction = "replace"
    
    init() {
        encoder.outputFormatting = .sortedKeys
    }
    
    func createIonLongFormDid(recoveryKey: ECPublicJwk,
                              updateKey: ECPublicJwk,
                              didDocumentKeys: [ECPublicJwk],
                              serviceEndpoints: [IdentifierDocumentServiceEndpoint]) throws -> String {
        
        let document = IONDocumentModel(fromJwks: didDocumentKeys, andServiceEndpoints: serviceEndpoints)
        let patches = [IONDocumentPatch(action: IdentifierFormatter.replaceAction, document: document)]
        
        let commitmentHash = try self.createCommitmentHash(usingJwk: updateKey)
        let delta = IONDocumentDeltaDescriptor(updateCommitment: commitmentHash, patches: patches)
        
        let suffixData = try self.createSuffixData(usingDelta: delta, recoveryKey: recoveryKey)
        
        let initialState = IONDocumentInitialState(suffixData: suffixData, delta:  delta)

        return try self.createLongFormIdentifier(usingInitialState: initialState)
    }
    
    private func createLongFormIdentifier(usingInitialState state: IONDocumentInitialState) throws -> String {
        
        let encodedPayload = try encoder.encode(state).base64URLEncodedString()
        let shortForm = try self.createShortFormIdentifier(usingSuffixData: state.suffixData)

        return shortForm + IdentifierFormatter.ionQueryValue + encodedPayload
    }
    
    private func createShortFormIdentifier(usingSuffixData data: IdentifierDocumentSuffixDescriptor) throws -> String {
        
        let encodedData = try encoder.encode(data)
        let hashedSuffixData = multihash.compute(from: encodedData).base64URLEncodedString()
        
        return IdentifierFormatter.ionPrefix + hashedSuffixData
    }
    
    private func createSuffixData(usingDelta delta: IONDocumentDeltaDescriptor, recoveryKey: ECPublicJwk) throws -> IdentifierDocumentSuffixDescriptor {
        
        let encodedDelta = try encoder.encode(delta)
        let patchDescriptorHash = multihash.compute(from: encodedDelta).base64URLEncodedString()
        let recoveryCommitmentHash = try self.createCommitmentHash(usingJwk: recoveryKey)
        
        return IdentifierDocumentSuffixDescriptor(deltaHash: patchDescriptorHash, recoveryCommitment: recoveryCommitmentHash)
    }
    
    // double hashed commitment hash
    private func createCommitmentHash(usingJwk jwk: ECPublicJwk) throws -> String {
        
        let canonicalizedPublicKey = try encoder.encode(jwk)
        let hashedPublicKey = multihash.compute(from: canonicalizedPublicKey)
        
        return multihash.compute(from: hashedPublicKey).base64URLEncodedString()
    }
}
