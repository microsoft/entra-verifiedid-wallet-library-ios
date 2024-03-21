/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

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
    
    func format(toWrap vcs: [RequestedVerifiableCredentialMapping],
                audience: String,
                nonce: String,
                expiryInSeconds exp: Int = 3000,
                identifier: String,
                signingKey: KeyContainer) throws -> VerifiablePresentation
    {
        let headers = headerFormatter.formatHeaders(identifier: identifier, signingKey: signingKey)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: exp)
        let verifiablePresentationDescriptor = try self.createVerifiablePresentationDescriptor(toWrap: vcs)
        
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
            throw TokenValidationError.UnableToCreateToken()
        }
        
        try token.sign(using: self.signer, withSecret: signingKey.keyReference)
        return token
    }
    
    private func createVerifiablePresentationDescriptor(toWrap vcs: [RequestedVerifiableCredentialMapping]) throws -> VerifiablePresentationDescriptor {
        
        return VerifiablePresentationDescriptor(context: [Constants.Context],
                                                type: [Constants.VerifiablePresentation],
                                                verifiableCredential: vcs.compactMap { vcMapping in vcMapping.vc.rawValue })
    }
}