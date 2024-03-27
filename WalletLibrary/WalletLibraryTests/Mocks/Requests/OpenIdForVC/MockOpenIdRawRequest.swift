/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockOpenIdRawRequest: OpenIdRawRequest, Equatable {
    
    enum MockOpenIdRawRequestError: Error {
        case mappingNotSupported
    }
    
    var type: RequestType
    
    var raw: Data?
    
    var primitiveClaims: [String : Any]?
    
    var nonce: String?
    
    var state: String?
    
    var issuer: String?
    
    var definitionId: String?
    
    init(raw: Data?, type: RequestType = .Presentation) {
        self.raw = raw
        self.type = type
        self.primitiveClaims = [:]
    }
    
    init(nonce: String?, state: String?, issuer: String?, definitionId: String?)
    {
        self.nonce = nonce
        self.state = state
        self.issuer = issuer
        self.definitionId = definitionId
        self.type = .Presentation
    }
    
    func map(using mapper: Mapping) throws -> PresentationRequestContent {
        throw MockOpenIdRawRequestError.mappingNotSupported
    }
    
    static func == (lhs: MockOpenIdRawRequest, rhs: MockOpenIdRawRequest) -> Bool 
    {
        return (lhs.raw != nil) && (rhs.raw != nil) && (lhs.raw! == rhs.raw!)
    }
}
