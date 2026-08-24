/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum IssuanceRequestValidatorError: Error, Equatable {
    case invalidSignature
    case noKeyIdInTokenHeader
    case keyIdInTokenHeaderMalformed
}

protocol IssuanceRequestValidating {
    func validate(request: SignedContract, usingKeys publicKeys: [IdentifierDocumentPublicKey]) throws
}

struct IssuanceRequestValidator: IssuanceRequestValidating {
    
    private let verifier: TokenVerifying
    
    init(verifier: TokenVerifying = TokenVerifier()) {
        self.verifier = verifier
    }
    
    func validate(request: SignedContract, usingKeys publicKeys: [IdentifierDocumentPublicKey]) throws {
        
        guard let kid = request.headers.keyId else
        {
            throw IssuanceRequestValidatorError.noKeyIdInTokenHeader
        }
        
        guard let keyIdentifier = DIDVerificationMethodIdentifier(keyId: kid) else {
            throw IssuanceRequestValidatorError.keyIdInTokenHeaderMalformed
        }

        if try request.verify(
            using: verifier,
            keys: publicKeys,
            keyIdentifier: keyIdentifier) {
            return
        }
        
        throw IssuanceRequestValidatorError.invalidSignature
    }
    
}
