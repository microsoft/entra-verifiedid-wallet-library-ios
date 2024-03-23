/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.PresentationRequest class.
 */
extension PresentationRequest: OpenIdRawRequest {
    
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
    
    var claims: [String : Any] {

//        return (try? self.content.map(using: Mapper())) ?? [:]
        
        if let serializedContent = try? JSONEncoder().encode(content)
        {
            return (try? JSONSerialization.jsonObject(with: serializedContent) as? [String: Any]) ?? [:]
        }
        
        return [:]
    }
}
