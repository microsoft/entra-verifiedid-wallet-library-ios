/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of building a Presentation Exchange Response Id Token in JWT format.
 * (Protocol used to help with mocking in tests)
 */
protocol PresentationExchangeIdTokenBuilding
{
    /// Builds Presentation Exchange Id Token from given input.
    func build(inputDescriptors: [InputDescriptorMapping],
               definitionId: String,
               audience: String,
               nonce: String,
               identifier: String,
               signingKey: KeyContainer) throws -> PresentationResponseToken
}

/**
 * Builds a Presentation Exchange Response Id Token in JWT format.
 */
class PresentationExchangeIdTokenBuilder: PresentationExchangeIdTokenBuilding
{
    /// Signer used to sign token.
    private let signer: TokenSigning
    
    /// Formats token headers.
    private let headerFormatter = JwsHeaderFormatter()
    
    init(signer: TokenSigning = Secp256k1Signer())
    {
        self.signer = signer
    }
    
    /// Builds Presentation Exchange Id Token from given input.
    func build(inputDescriptors: [InputDescriptorMapping],
               definitionId: String,
               audience: String,
               nonce: String,
               identifier: String,
               signingKey: KeyContainer) throws -> PresentationResponseToken
    {
        let submission = PresentationSubmission(id: UUID().uuidString,
                                                definitionId: definitionId,
                                                inputDescriptorMap: inputDescriptors)
        let timeConstraints = TokenTimeConstraints()
        let vpTokenResponse = VPTokenResponseDescription(presentationSubmission: submission)
        let claims = PresentationResponseClaims(subject: identifier,
                                                audience: audience,
                                                vpTokenDescription: [vpTokenResponse],
                                                nonce: nonce,
                                                iat: timeConstraints.issuedAt,
                                                exp: timeConstraints.expiration)
        return try createToken(content: claims, signingKey: signingKey)
    }
    
    private func createToken(content: PresentationResponseClaims,
                             signingKey: KeyContainer) throws -> PresentationResponseToken
    {
        let headers = headerFormatter.formatHeaders(identifier: content.subject,
                                                    signingKey: signingKey)
        
        guard var token = JwsToken(headers: headers, content: content) else 
        {
            throw TokenValidationError.UnableToCreateToken(ofType: String(describing: PresentationResponseToken.self))
        }
        
        try token.sign(using: signer,
                       withSecret: signingKey.keyReference)
        
        return token
    }
}
