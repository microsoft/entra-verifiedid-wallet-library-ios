/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Input to start a request from a openid-vc url.
 */
public class URLInput: VerifiedIdClientInput {
    
    enum URLVerifiedIdClientInputError: Error {
        case inputNotSupportedURL(input: String)
    }
    
    let url: URL
    
    /**
     * - Parameters:
     *      - url: the url that will initate the request.
     */
    public init(url: String) throws {
        
        guard let url = URL(string: url) else {
            throw URLVerifiedIdClientInputError.inputNotSupportedURL(input: url)
        }
        
        self.url = url
    }
}
