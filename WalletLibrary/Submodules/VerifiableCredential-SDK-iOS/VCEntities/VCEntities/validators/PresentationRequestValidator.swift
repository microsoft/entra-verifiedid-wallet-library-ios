/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationRequestValidatorError: Error {
    case didMethodNotSupported
    case keyIdInTokenHeaderMalformed
    case invalidResponseModeValue
    case invalidResponseTypeValue
    case invalidScopeValue
    case invalidSignature
    case clientIdentifierDoesNotMatchSigner
    case issuerDoesNotMatchSigner
    case noExpirationPresent
    case noRegistrationPresent
    case noKeyIdInTokenHeader
    case responseSigningAlgorithmNotSupportedForVCs
    case responseSigningAlgorithmNotSupportedForVPs
    case subjectIdentifierTypeNotSupported
    case tokenExpired
}

protocol RequestValidating {
    func validate(request: PresentationRequestToken, usingKeys publicKeys: [IdentifierDocumentPublicKey]) throws
}

struct PresentationResponseCapability: Equatable {
    let method: String
    let algorithm: String

    static let supported = [
        PresentationResponseCapability(method: "did:ion", algorithm: "ES256K"),
        PresentationResponseCapability(method: "did:jwk", algorithm: "ES256")
    ]

    static func forIdentifier(_ identifier: HolderIdentifier) -> PresentationResponseCapability? {
        return supported.first { $0.method == identifier.method && $0.algorithm == identifier.algorithm }
    }
}

extension RegistrationClaims {
    // VC signatures belong to issuers, not to the holder signing the surrounding VP.
    private static let supportedCredentialAlgorithms: Set<String> = ["ES256K", "ES256", "EdDSA"]

    var passesLegacyCapabilityChecks: Bool {
        return (subjectIdentifierTypesSupported?.contains(VCEntitiesConstants.SUBJECT_IDENTIFIER_TYPE_DID) ?? true)
            && (vpFormats?.jwtVP?.algorithms?.contains(VCEntitiesConstants.ALGORITHM_SUPPORTED_IN_VP) ?? true)
            && (vpFormats?.jwtVC?.algorithms?.contains(VCEntitiesConstants.ALGORITHM_SUPPORTED_IN_VP) ?? true)
    }

    func validateResponseCapabilities(_ capabilities: [PresentationResponseCapability]) throws {
        // Preserve acceptance of legacy metadata without imposing new holder inventory requirements.
        if !passesLegacyCapabilityChecks {
            let matchingMethods = capabilities.filter {
                subjectIdentifierTypesSupported?.contains($0.method) ?? true
            }
            if subjectIdentifierTypesSupported != nil && matchingMethods.isEmpty {
                throw PresentationRequestValidatorError.subjectIdentifierTypeNotSupported
            }

            if let algorithms = vpFormats?.jwtVP?.algorithms,
               !matchingMethods.contains(where: { algorithms.contains($0.algorithm) }) {
                throw PresentationRequestValidatorError.responseSigningAlgorithmNotSupportedForVPs
            }
        }

        if let algorithms = vpFormats?.jwtVC?.algorithms,
           Self.supportedCredentialAlgorithms.isDisjoint(with: algorithms) {
            throw PresentationRequestValidatorError.responseSigningAlgorithmNotSupportedForVCs
        }
    }

    func supportsHolder(_ identifier: HolderIdentifier) -> Bool {
        guard !passesLegacyCapabilityChecks else {
            return true
        }
        guard let capability = PresentationResponseCapability.forIdentifier(identifier) else {
            return false
        }
        return (subjectIdentifierTypesSupported?.contains(capability.method) ?? true)
            && (vpFormats?.jwtVP?.algorithms?.contains(capability.algorithm) ?? true)
    }
}

struct PresentationRequestValidator: RequestValidating {
    
    private let verifier: TokenVerifying
    private let validateIdentity: Bool
    private let responseCapabilities: [PresentationResponseCapability]
    
    init(verifier: TokenVerifying = TokenVerifier(),
         validateIdentity: Bool = true,
         responseCapabilities: [PresentationResponseCapability] = PresentationResponseCapability.supported) {
        self.verifier = verifier
        self.validateIdentity = validateIdentity
        self.responseCapabilities = responseCapabilities.filter { PresentationResponseCapability.supported.contains($0) }
    }
    
    func validate(request: PresentationRequestToken, usingKeys publicKeys: [IdentifierDocumentPublicKey]) throws {
        try validate(expiration: request.content.exp)
        try validate(request.content.scope, equals: VCEntitiesConstants.SCOPE, throws: PresentationRequestValidatorError.invalidScopeValue)
        try validate(request.content.responseMode, equals: VCEntitiesConstants.RESPONSE_MODE, throws: PresentationRequestValidatorError.invalidResponseModeValue)
        try validate(request.content.responseType, equals: VCEntitiesConstants.RESPONSE_TYPE, throws: PresentationRequestValidatorError.invalidResponseTypeValue)
        
        guard let registration = request.content.registration else {
            throw PresentationRequestValidatorError.noRegistrationPresent
        }
        
        try registration.validateResponseCapabilities(responseCapabilities)
        
        try validate(token: request, using: publicKeys)
    }
    
    private func validate(token: PresentationRequestToken,
                          using keys: [IdentifierDocumentPublicKey]) throws {
        
        guard let kid = token.headers.keyId else
        {
            throw PresentationRequestValidatorError.noKeyIdInTokenHeader
        }
        
        guard let keyIdentifier = DIDVerificationMethodIdentifier(keyId: kid) else {
            throw PresentationRequestValidatorError.keyIdInTokenHeaderMalformed
        }

        if validateIdentity {
            guard token.content.clientID == keyIdentifier.did else {
                throw PresentationRequestValidatorError.clientIdentifierDoesNotMatchSigner
            }

            if let issuer = token.content.issuer, issuer != keyIdentifier.did {
                throw PresentationRequestValidatorError.issuerDoesNotMatchSigner
            }
        }

        if try token.verify(
            using: verifier,
            keys: keys,
            keyIdentifier: keyIdentifier) {
            return
        }
        
        throw PresentationRequestValidatorError.invalidSignature
    }
    
    private func validate(expiration: Int?) throws {
        guard let exp = expiration else { throw PresentationRequestValidatorError.noExpirationPresent }
        if getExpirationDeadlineInSeconds() > exp { throw PresentationRequestValidatorError.tokenExpired }
    }
    
    private func validate(_ value: String?, equals correctValue: String, throws error: Error) throws {
        guard value == correctValue else { throw error }
    }
    
    private func getExpirationDeadlineInSeconds(expirationCheckTimeOffsetInSeconds: Int = 300) -> Int {
        let currentTimeInSeconds = Int((Date().timeIntervalSince1970).rounded(.down))
        return currentTimeInSeconds - expirationCheckTimeOffsetInSeconds
    }
}
