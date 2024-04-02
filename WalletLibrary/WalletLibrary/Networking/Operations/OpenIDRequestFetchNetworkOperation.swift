/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct OpenID4VCINetworkConstants
{
    static let InteropProfileVersion = "oid4vci-interop-profile-version=0.0.1"
    static let PreferHeaderField = "prefer"
}

/**
 * The Network Operation to prefer the OpenID4VCI Request.
 */
struct OpenIDRequestFetchNetworkOperation: WalletLibraryFetchOperation
{
    typealias ResponseBody = Data
    typealias Decoder = ServiceResponseDecoder
    
    var decoder = ServiceResponseDecoder()
    
    var urlSession: URLSession
    
    var urlRequest: URLRequest
    
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?)
    {
        self.urlSession = urlSession
        self.urlRequest = URLRequest(url: url)
        self.correlationVector = correlationVector
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}

/// A Simple Service Response Decoder to just return the Data.
// TODO: Update to OpenID4VCIRequest Decoder if needed in next PR.
struct ServiceResponseDecoder: Decoding
{
    func decode(data: Data) throws -> Data 
    {
        return data
    }
}
