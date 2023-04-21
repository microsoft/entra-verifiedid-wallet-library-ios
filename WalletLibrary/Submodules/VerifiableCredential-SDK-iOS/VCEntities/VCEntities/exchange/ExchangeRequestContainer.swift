/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum ExchangeRequestError: Error {
    case noAudienceFound
}

struct ExchangeRequestContainer {
    
    let exchangeableVerifiableCredential: VerifiableCredential
    
    let newOwnerDid: String
    
    let currentOwnerIdentifier: Identifier
    
    let audience: String
    
    init(exchangeableVerifiableCredential: VerifiableCredential,
                newOwnerDid: String,
                currentOwnerIdentifier: Identifier) throws {
        
        guard let requestAudience = exchangeableVerifiableCredential.content.vc?.exchangeService?.id else {
            throw ExchangeRequestError.noAudienceFound
        }
        
        self.audience = requestAudience
        self.exchangeableVerifiableCredential = exchangeableVerifiableCredential
        self.newOwnerDid = newOwnerDid
        self.currentOwnerIdentifier = currentOwnerIdentifier
    }

}
