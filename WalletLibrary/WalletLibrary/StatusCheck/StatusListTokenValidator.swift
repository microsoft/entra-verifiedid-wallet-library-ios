/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/// Claims for a status list credential JWT. Only the fields needed to bind and time-box the token are
/// modelled; `encodedList` / `statusPurpose` are read from the raw payload, so decoding never fails on
/// list shape.
struct StatusListClaims: Claims {
    let iss: String?
    let exp: Int?
}

enum StatusListValidationError: Error, Equatable {
    case emptyIssuer
    case missingKeyId
    case malformedKeyId
    case issuerMismatch
    case noPublicKeysInIdentifierDocument
    case invalidSignature
    case expired
}

/**
 * Verifies a fetched StatusList2021 credential JWT before its bits are trusted: the signature must
 * verify against the issuer's resolved DID document, the signer (token `kid` DID and payload `iss`)
 * must be the credential's own issuer, and any `exp` must be in the future (with clock skew).
 *
 * This is defense-in-depth — the issuance/presentation server remains authoritative — but it stops a
 * man-in-the-middle from forging a "valid" list. Modelled on `DomainLinkageCredentialValidator`.
 */
class StatusListTokenValidator {

    private let didResolver: DiscoveryNetworking
    private let tokenVerifier: TokenVerifying
    private let clockSkewSeconds: TimeInterval

    init(didResolver: DiscoveryNetworking,
         tokenVerifier: TokenVerifying = TokenVerifier(),
         clockSkewSeconds: TimeInterval = 300) {
        self.didResolver = didResolver
        self.tokenVerifier = tokenVerifier
        self.clockSkewSeconds = clockSkewSeconds
    }

    func validate(_ token: JwsToken<StatusListClaims>,
                  expectedIssuerDid: String,
                  now: Date,
                  preResolvedDocument: IdentifierDocument? = nil) async throws {
        guard !expectedIssuerDid.isEmpty else {
            throw StatusListValidationError.emptyIssuer
        }

        guard let keyId = token.headers.keyId, !keyId.isEmpty else {
            throw StatusListValidationError.missingKeyId
        }

        let signerDid = String(keyId.split(separator: "#").first ?? "")
        guard !signerDid.isEmpty else {
            throw StatusListValidationError.malformedKeyId
        }
        guard signerDid == expectedIssuerDid else {
            throw StatusListValidationError.issuerMismatch
        }
        if let issuer = token.content.iss, !issuer.isEmpty, issuer != expectedIssuerDid {
            throw StatusListValidationError.issuerMismatch
        }

        // Reuse a document the caller already resolved for `expectedIssuerDid`; otherwise fetch it.
        let document: IdentifierDocument
        if let preResolvedDocument = preResolvedDocument {
            document = preResolvedDocument
        } else {
            document = try await didResolver.getDocument(from: expectedIssuerDid)
        }
        try verifySignature(of: token, keyId: keyId, document: document)

        if let exp = token.content.exp {
            let expiry = Date(timeIntervalSince1970: TimeInterval(exp) + clockSkewSeconds)
            if expiry < now {
                throw StatusListValidationError.expired
            }
        }
    }

    private func verifySignature(of token: JwsToken<StatusListClaims>,
                                 keyId: String,
                                 document: IdentifierDocument) throws {
        guard let keys = document.verificationMethod, !keys.isEmpty else {
            throw StatusListValidationError.noPublicKeysInIdentifierDocument
        }

        let fragments = keyId.split(separator: "#")
        let keyFragment = fragments.count == 2 ? "#" + String(fragments[1]) : nil

        let matchingKeys = keys.filter { $0.id == keyId || (keyFragment != nil && $0.id == keyFragment) }
        for key in matchingKeys where verify(token, with: key) {
            return
        }
        for key in keys where verify(token, with: key) {
            return
        }

        throw StatusListValidationError.invalidSignature
    }

    private func verify(_ token: JwsToken<StatusListClaims>, with key: IdentifierDocumentPublicKey) -> Bool {
        return (try? token.verify(using: tokenVerifier, withPublicKey: key.publicKeyJwk)) == true
    }
}
