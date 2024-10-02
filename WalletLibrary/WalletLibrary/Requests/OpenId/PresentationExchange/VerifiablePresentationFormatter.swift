/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * Formats a Verifiable Presentation token in JWT format which adheres to the Presentation Exchange protocol.
 */
class VerifiablePresentationFormatter
{
    private struct Constants 
    {
        static let Context = "https://www.w3.org/2018/credentials/v1"
        static let VerifiablePresentation = "VerifiablePresentation"
    }
    
    let signer: TokenSigning
    let headerFormatter = JwsHeaderFormatter()
    
    init(signer: TokenSigning = Secp256k1Signer())
    {
        self.signer = signer
    }
    
    /// The method signature from the old VC SDK implementation.
    func format(toWrap vcs: [RequestedVerifiableCredentialMapping],
                audience: String,
                nonce: String,
                expiryInSeconds exp: Int = 3000,
                identifier: String,
                signingKey: KeyContainer) throws -> VerifiablePresentation
    {
        let rawVCs = try vcs.compactMap { try $0.vc.serialize() }
        return try format(rawVCs: rawVCs,
                          audience: audience,
                          nonce: nonce,
                          identifier: identifier,
                          signingKey: signingKey)
    }
    
    /// The method signature from the old VC SDK implementation.
    func format(toWrap vcs: [RequestedVerifiableCredentialMapping],
                audience: String,
                nonce: String,
                expiryInSeconds exp: Int = 3000,
                identifier: VerifiedIdIdentifier) throws -> VerifiablePresentation
    {
        let rawVCs = try vcs.compactMap { try $0.vc.serialize() }
        
        let headers = headerFormatter.formatHeaders(identifier: identifier)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: exp)
        let verifiablePresentationDescriptor = VerifiablePresentationDescriptor(context: [Constants.Context],
                                                                                type: [Constants.VerifiablePresentation],
                                                                                verifiableCredential: rawVCs)
        
        let vpClaims = VerifiablePresentationClaims(vpId: UUID().uuidString,
                                                    verifiablePresentation: verifiablePresentationDescriptor,
                                                    issuerOfVp: identifier.id,
                                                    audience: audience,
                                                    iat: timeConstraints.issuedAt,
                                                    nbf: timeConstraints.issuedAt,
                                                    exp: timeConstraints.expiration,
                                                    nonce: nonce)
        
        guard var token = JwsToken(headers: headers, content: vpClaims) else
        {
            throw TokenValidationError.UnableToCreateToken(ofType: String(describing: VerifiablePresentation.self))
        }
        
        try token.sign(using: identifier)
        return token
    }
    
    /// Takes the serialized Verifiable Credentials and creates Verifiable Presentation token with other given input
    /// Signed by the signing key which should belong to the identifier.
    func format(rawVCs: [String],
                audience: String,
                nonce: String,
                expiryInSeconds exp: Int = 3000,
                identifier: String,
                signingKey: KeyContainer) throws -> VerifiablePresentation
    {
        let headers = headerFormatter.formatHeaders(identifier: identifier, signingKey: signingKey)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: exp)
        let verifiablePresentationDescriptor = VerifiablePresentationDescriptor(context: [Constants.Context],
                                                                                type: [Constants.VerifiablePresentation],
                                                                                verifiableCredential: rawVCs)
        
        let vpClaims = VerifiablePresentationClaims(vpId: UUID().uuidString,
                                                    verifiablePresentation: verifiablePresentationDescriptor,
                                                    issuerOfVp: identifier,
                                                    audience: audience,
                                                    iat: timeConstraints.issuedAt,
                                                    nbf: timeConstraints.issuedAt,
                                                    exp: timeConstraints.expiration,
                                                    nonce: nonce)
        
        guard var token = JwsToken(headers: headers, content: vpClaims) else
        {
            throw TokenValidationError.UnableToCreateToken(ofType: String(describing: VerifiablePresentation.self))
        }
        
        try token.sign(using: signer, withSecret: signingKey.keyReference)
        return token
    }
}
