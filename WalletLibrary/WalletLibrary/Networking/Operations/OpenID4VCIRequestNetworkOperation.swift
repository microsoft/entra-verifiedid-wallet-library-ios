/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The constraints for issuance and display information of a credential,
 */
struct OpenID4VCIRequestNetworkOperation: WalletLibraryFetchOperation
{
    typealias ResponseBody = Data
    typealias Decoder = ServiceResponseDecoder
    
    var decoder = ServiceResponseDecoder()
    
    var urlSession: URLSession
    
    var urlRequest: URLRequest
    
    var correlationVector: VerifiedIdCorrelationHeader?
    
    let PreferHeaderValue = "oid4vci-interop-profile-version=0.0.1"
    
    let PreferHeaderField = "prefer"
    
    init(url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?)
    {
        self.urlSession = urlSession
        self.urlRequest = URLRequest(url: url)
        self.correlationVector = correlationVector
        
        /// Adds value to prefer header, appending if value already exists.
        urlRequest.addValue(PreferHeaderValue, forHTTPHeaderField: PreferHeaderField)
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}

struct ServiceResponseDecoder: Decoding
{
    func decode(data: Data) throws -> Data {
        return data
    }
    
    typealias ResponseBody = Data
    
    
}
