/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

class VerifiablePresentationFormatter {
    
    private struct Constants {
        static let Context = "https://www.w3.org/2018/credentials/v1"
        static let VerifiablePresentation = "VerifiablePresentation"
    }
    
    let signer: TokenSigning
    let headerFormatter = JwsHeaderFormatter()
    
    public init(signer: TokenSigning) {
        self.signer = signer
    }
    
    func format(toWrap vcs: RequestedVerifiableCredentialMap,
                withAudience audience: String,
                withNonce nonce: String,
                withExpiryInSeconds exp: Int,
                usingIdentifier identifier: Identifier,
                andSignWith key: KeyContainer) throws -> VerifiablePresentation {
        
        let headers = headerFormatter.formatHeaders(usingIdentifier: identifier, andSigningKey: identifier.didDocumentKeys.first!)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: exp)
        let verifiablePresentationDescriptor = try self.createVerifiablePresentationDescriptor(toWrap: vcs)
        
        let vpClaims = VerifiablePresentationClaims(vpId: UUID().uuidString,
                                                    verifiablePresentation: verifiablePresentationDescriptor,
                                                    issuerOfVp: identifier.longFormDid,
                                                    audience: audience,
                                                    iat: timeConstraints.issuedAt,
                                                    nbf: timeConstraints.issuedAt,
                                                    exp: timeConstraints.expiration,
                                                    nonce: nonce)
        
        guard var token = JwsToken<VerifiablePresentationClaims>(headers: headers, content: vpClaims) else {
            throw FormatterError.unableToFormToken
        }
        
        try token.sign(using: self.signer, withSecret: key.keyReference)
        return token
    }
    
    private func createVerifiablePresentationDescriptor(toWrap vcs: RequestedVerifiableCredentialMap) throws -> VerifiablePresentationDescriptor {
        
        return VerifiablePresentationDescriptor(context: [Constants.Context],
                                                type: [Constants.VerifiablePresentation],
                                                verifiableCredential: vcs.compactMap { vcMapping in vcMapping.vc.rawValue })
    }
}
