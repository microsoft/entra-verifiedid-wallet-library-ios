/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.PresentationRequest class.
 */
extension VCEntities.PresentationRequest: OpenIdRawRequest {
    
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
}
