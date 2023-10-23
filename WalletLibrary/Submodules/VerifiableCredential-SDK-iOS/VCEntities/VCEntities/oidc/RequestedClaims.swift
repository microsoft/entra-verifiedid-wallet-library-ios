/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Claims that are being requested in an OpenID Connect Request.
struct RequestedClaims: Codable, Equatable {
    
    /// Request Verifiable Presentation Tokens.
    let vpToken: RequestedVPToken

    enum CodingKeys: String, CodingKey {
        case vpToken = "vp_token"
    }
    
    init(vpToken: RequestedVPToken) {
        self.vpToken = vpToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let vpTokens = try? container.decode(RequestedVPToken.self, forKey: .vpToken) {
             self.vpToken = vpTokens
        } else {
             throw DecodingError.unableToDecodeToken
         }
    }
}
