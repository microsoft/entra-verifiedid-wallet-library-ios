/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/


class IssuanceVPFormatter 
{
    
    private struct Constants 
    {
        static let Context = "https://www.w3.org/2018/credentials/v1"
        static let VerifiablePresentation = "VerifiablePresentation"
    }

    private let headerFormatter: JwsHeaderFormatter
    
    init() 
    {
        self.headerFormatter = JwsHeaderFormatter()
    }
    
    func format(toWrap vc: VerifiableCredential,
                withAudience audience: String,
                withExpiryInSeconds exp: Int,
                usingIdentifier identifier: HolderIdentifier) throws -> VerifiablePresentation
    {
        let headers = headerFormatter.formatHeaders(identifier: identifier)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: exp)
        let verifiablePresentationDescriptor = try self.createVerifiablePresentationDescriptor(toWrap: vc)
        
        let vpClaims = VerifiablePresentationClaims(vpId: UUID().uuidString,
                                                    verifiablePresentation: verifiablePresentationDescriptor,
                                                    issuerOfVp: identifier.id,
                                                    audience: audience,
                                                    iat: timeConstraints.issuedAt,
                                                    nbf: timeConstraints.issuedAt,
                                                    exp: timeConstraints.expiration,
                                                    nonce: nil)
        
        guard var token = JwsToken<VerifiablePresentationClaims>(headers: headers, content: vpClaims) else {
            throw FormatterError.unableToFormToken
        }
        
        try token.sign(using: identifier)
        return token
    }
    
    private func createVerifiablePresentationDescriptor(toWrap vc: VerifiableCredential) throws -> VerifiablePresentationDescriptor 
    {
        guard let rawVC = vc.rawValue else 
        {
            throw FormatterError.unableToGetRawValueOfVerifiableCredential
        }
        
        return VerifiablePresentationDescriptor(context: [Constants.Context],
                                                type: [Constants.VerifiablePresentation],
                                                verifiableCredential: [rawVC])
    }
}
