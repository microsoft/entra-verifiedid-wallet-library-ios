/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Claims that are being requested in an OpenID Connect Request.
public struct RequestedClaims: Codable, Equatable {
    
    /// Request Verifiable Presentation Tokens.
    public let vpToken: RequestedVPToken?
    
    public init(vpToken: RequestedVPToken?) {
        self.vpToken = vpToken
    }

    enum CodingKeys: String, CodingKey {
        case vpToken = "vp_token"
    }
}
