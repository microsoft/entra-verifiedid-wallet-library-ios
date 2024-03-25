/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * Formats a Verifiable Presentation token in JWT format which adheres to the Presentation Exchange protocol.
 */
class PresentationExchangeIdTokenBuilder
{
    let signer: TokenSigning
    let headerFormatter = JwsHeaderFormatter()
    
    init(signer: TokenSigning = Secp256k1Signer())
    {
        self.signer = signer
    }
    
    func build() throws -> PresentationResponseToken
    {
        throw VerifiedIdError(message: "", code: "")
    }
}
