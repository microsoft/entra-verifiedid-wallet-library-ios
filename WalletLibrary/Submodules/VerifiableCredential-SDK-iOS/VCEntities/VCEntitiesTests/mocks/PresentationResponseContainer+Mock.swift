/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

extension PresentationResponseContainer {
    
    static func mock(using requestedVpTokens: [RequestedVPToken]) throws -> PresentationResponseContainer {
        let requestedClaims = RequestedClaims(vpToken: requestedVpTokens)
        let claims = PresentationRequestClaims(clientID: "mock did",
                                               redirectURI: "mock audience",
                                               claims: requestedClaims,
                                               state: "mock state",
                                               nonce: "mock nonce")
        let token = PresentationRequestToken(headers: Header(), content: claims)!
        let request = PresentationRequest(from: token, linkedDomainResult: .linkedDomainMissing)
        return try PresentationResponseContainer(from: request)
    }
}
