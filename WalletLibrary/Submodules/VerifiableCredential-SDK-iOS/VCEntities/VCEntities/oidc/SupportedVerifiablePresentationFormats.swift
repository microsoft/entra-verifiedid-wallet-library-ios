/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Supported Verifiable Presentation Formats for response.
public struct SupportedVerifiablePresentationFormats: Codable, Equatable {
    
    /// Supported algorithms for verifiable presentations contained in response.
    public let jwtVP: AllowedAlgorithms?
    
    /// Supported algorithms for verifiable credentials contained in response.
    public let jwtVC: AllowedAlgorithms?

    enum CodingKeys: String, CodingKey {
        case jwtVP = "jwt_vp"
        case jwtVC = "jwt_vc"
    }
    
    public init(jwtVP: AllowedAlgorithms? = nil, jwtVC: AllowedAlgorithms? = nil) {
        self.jwtVP = jwtVP
        self.jwtVC = jwtVC
    }
}
