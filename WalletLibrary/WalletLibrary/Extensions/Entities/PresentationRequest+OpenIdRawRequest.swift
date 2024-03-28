/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.PresentationRequest class.
 */
extension PresentationRequest: OpenIdRawRequest 
{
    /// If prompt equals create, the request is an issuance request.
    private var promptValueForIssuance: String {
        "create"
    }
    
    var type: RequestType {
        if content.prompt == promptValueForIssuance {
            return .Issuance
        }
        
        return .Presentation
    }
    
    /// The raw representation of the request.
    var raw: Data? {
        do {
            let serializedToken = try self.token.serialize()
            return serializedToken.data(using: .utf8)
        } catch {
            return nil
        }
    }
    
    var primitiveClaims: [String : Any]? {
        return token.primitiveClaims
    }
    
    var nonce: String? {
        return content.nonce
    }
    
    var state: String? {
        return content.state
    }
    
    var clientId: String? {
        return content.clientID
    }
    
    var responseURL: URL? {
        return content.redirectURI.flatMap { URL(string: $0) }
    }
    
    /// Should only be one definition Id per request.
    var definitionId: String? {
        return content.claims?.vpToken.first?.presentationDefinition?.id
    }
}
