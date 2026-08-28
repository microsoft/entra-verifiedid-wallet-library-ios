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
    let nbf: Int?
}

enum StatusListValidationError: Error, Equatable {
    case emptyIssuer
    case missingKeyId
    case malformedKeyId
    case issuerMismatch
    case identifierDocumentMismatch
    case noPublicKeysInIdentifierDocument
    case invalidSignature
    case missingExpiry
    case expired
    case notYetValid
}

/**
 * Verifies a fetched StatusList2021 credential JWT before its bits are trusted: the signature must
 * verify against the `kid`-referenced key in the issuer's resolved DID document, the signer (token
 * `kid` DID and payload `iss`) must be the credential's own issuer, and a required `exp` must be in
 * the future (with clock skew); any `nbf` must not be in the future.
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
        guard document.id == expectedIssuerDid else {
            throw StatusListValidationError.identifierDocumentMismatch
        }
        try verifySignature(of: token, keyId: keyId, document: document)

        // `exp` is required: a status list with no expiry would be trusted indefinitely, letting a
        // replayed older "all-clear" list mask a later revocation. A missing or past expiry throws, so
        // the caller degrades to `.unknown` (fail-open) rather than trusting a stale list as "valid".
        guard let exp = token.content.exp else {
            throw StatusListValidationError.missingExpiry
        }
        if Date(timeIntervalSince1970: TimeInterval(exp) + clockSkewSeconds) < now {
            throw StatusListValidationError.expired
        }

        // Reject a token that is not yet valid (`nbf` in the future, beyond clock skew).
        if let nbf = token.content.nbf,
           Date(timeIntervalSince1970: TimeInterval(nbf) - clockSkewSeconds) > now {
            throw StatusListValidationError.notYetValid
        }
    }

    private func verifySignature(of token: JwsToken<StatusListClaims>,
                                 keyId: String,
                                 document: IdentifierDocument) throws {
        guard let keys = document.verificationMethod, !keys.isEmpty else {
            throw StatusListValidationError.noPublicKeysInIdentifierDocument
        }

        // Bind verification to the `kid`-referenced key only (matched by full id or `#fragment`), like
        // `DomainLinkageCredentialValidator` — not "any key in the document" — for tighter key binding.
        guard let keyIdentifier = DIDVerificationMethodIdentifier(keyId: keyId) else {
            throw StatusListValidationError.malformedKeyId
        }

        if token.verify(
            using: tokenVerifier,
            keys: keys,
            keyIdentifier: keyIdentifier) {
            return
        }

        throw StatusListValidationError.invalidSignature
    }
}
