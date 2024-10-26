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
               identifier: HolderIdentifier) throws -> PresentationResponseToken
}

/**
 * Builds a Presentation Exchange Response Id Token in JWT format.
 */
class PresentationExchangeIdTokenBuilder: PresentationExchangeIdTokenBuilding
{
    /// Formats token headers.
    private let headerFormatter: JwsHeaderFormatter
    
    init()
    {
        self.headerFormatter = JwsHeaderFormatter()
    }
    
    /// Builds Presentation Exchange Id Token from given input.
    func build(inputDescriptors: [InputDescriptorMapping],
               definitionId: String,
               audience: String,
               nonce: String,
               identifier: HolderIdentifier) throws -> PresentationResponseToken
    {
        let content = createTokenContent(inputDescriptors: inputDescriptors,
                                         definitionId: definitionId,
                                         audience: audience,
                                         nonce: nonce,
                                         identifier: identifier.id)
        return try createToken(content: content, holderIdentifier: identifier)
    }
    
    private func createTokenContent(inputDescriptors: [InputDescriptorMapping],
                                    definitionId: String,
                                    audience: String,
                                    nonce: String,
                                    identifier: String) -> PresentationResponseClaims
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
        return claims
    }
    
    private func createToken(content: PresentationResponseClaims,
                             holderIdentifier: HolderIdentifier) throws -> PresentationResponseToken
    {
        let headers = headerFormatter.formatHeaders(identifier: holderIdentifier)
        
        guard var token = JwsToken(headers: headers, content: content) else
        {
            throw TokenValidationError.UnableToCreateToken(ofType: String(describing: PresentationResponseToken.self))
        }
        
        try token.sign(using: holderIdentifier)
        
        return token
    }
}
