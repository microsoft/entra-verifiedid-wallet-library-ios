/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Input to start a request from a openid-vc url.
 */
public class SIOPURLInput: VerifiedIdClientInput {
    
    enum URLVerifiedIdClientInputError: Error {
        case inputNotSupportedURL(input: String)
    }
    
    let url: URL
    
    /**
     * - Parameters:
     *      - url: the url that will initate the request.
     */
    public init(_ url: String) throws {
        
        guard let url = URL(string: url) else {
            throw URLVerifiedIdClientInputError.inputNotSupportedURL(input: url)
        }
        
        self.url = url
    }
    
    func resolve(with configuration: VerifiedIdClientConfiguration) throws -> any VerifiedIdRequest {
        let supportedProtocolConfiguration = configuration.protocolConfigurations.filter {
            $0.supportedInput.contains {
                $0 == SIOPURLInput.self
            }
        }.first
        
        guard let supportedProtocolConfiguration = supportedProtocolConfiguration else {
            throw VerifiedIdClientError.protocolNotSupported
        }
        
        let request = supportedProtocolConfiguration.protocolHandler.handle(input: self, with: configuration)
        return request
    }
}
