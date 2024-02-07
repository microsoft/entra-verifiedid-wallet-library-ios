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
struct OpenID4VCIRequestNetworkOperation: WalletLibraryFetchOperation
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
        
        /// Adds value to prefer header, appending if value already exists.
        let preferHeader = [OpenID4VCINetworkConstants.PreferHeaderField: OpenID4VCINetworkConstants.InteropProfileVersion]
        addHeadersToURLRequest(headers: preferHeader)
        
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
