/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

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
        
        let keyIdComponents = kid.split(separator: "#").map { String($0) }
        
        guard keyIdComponents.count == 2 else {
            throw IssuanceRequestValidatorError.keyIdInTokenHeaderMalformed
        }
        
        let publicKeyId = "#\(keyIdComponents[1])"
        
        /// check if key id is equal to keyId fragment in token header, and if so, validate signature. Else, continue loop.
        for key in publicKeys {
            if key.id == publicKeyId,
               try request.verify(using: verifier, withPublicKey: key.publicKeyJwk) {
                return
            }
        }
        
        throw IssuanceRequestValidatorError.invalidSignature
    }
    
}
