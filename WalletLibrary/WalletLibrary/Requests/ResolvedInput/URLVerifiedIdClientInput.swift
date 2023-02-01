/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public class URLVerifiedIdClientInput: InternalVerifiedIdClientInput {
    
    enum URLVerifiedIdClientInputError: Error {
        case notImplemented
    }
    
    let url: String
    
    var raw: Data?
    
    public init(_ url: String) {
        self.url = url
    }
    
    func resolve(with configuration: VerifiedIdClientConfiguration) throws -> RequestProtocol {
        
        guard let url = URLComponents(string: url) else {
            throw VerifiedIdClientError.notImplemented
        }
        
        switch url.scheme {
        case "https":
            this.raw = result
            return .ISSUANCEV1
        case "openid-vc":
            return .SIOP
        default:
            throw VerifiedIdClientError.notImplemented
        }
    }
}
