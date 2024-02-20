/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Wallet Library Fetch Operation.
 */
protocol WalletLibraryFetchOperation: InternalNetworkOperation where ResponseBody: Decodable
{
    associatedtype Decoder = SimpleDecoder<ResponseBody>
    
    init(url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?)
}

/**
 * An extension for the `WalletLibraryFetchOperation` to have a simple decoder
 * that just decodes JSON by default.
 */
extension WalletLibraryFetchOperation
{
    var decoder: SimpleDecoder<ResponseBody>
    {
        SimpleDecoder()
    }
}

/**
 * The Wallet Library Post Operation.
 */
protocol WalletLibraryPostOperation: InternalPostOperation where ResponseBody: Decodable, RequestBody: Encodable
{
    associatedtype Encoder = SimpleEncoder<RequestBody>
    associatedtype Decoder = SimpleDecoder<ResponseBody>

    init(requestBody: RequestBody,
         url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?) throws
}

/**
 * An extension for the `WalletLibraryPostOperation`
 * to have a simple decoder and a simple encoder to handle JSON by default.
 */
extension WalletLibraryPostOperation
{
    var encoder: SimpleEncoder<RequestBody>
    {
        SimpleEncoder()
    }
    
    var decoder: SimpleDecoder<ResponseBody>
    {
        SimpleDecoder()
    }
}

/**
 * A Simple Encoder to act as default to handle JSON.
 */
struct SimpleEncoder<T: Encodable>: Encoding
{
    func encode(value: T) throws -> Data
    {
        try JSONEncoder().encode(value)
    }
}

/**
 * A Simple Decoder to act as default to handle JSON.
 */
struct SimpleDecoder<T: Decodable>: Decoding
{
    func decode(data: Data) throws -> T
    {
        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension InternalNetworkOperation
{
    /// A helper method classes that implement this protocol can use to inject additional headers into the URLRequest.
    mutating func addHeadersToURLRequest(headers: [String: String]?)
    {
        if let headers = headers
        {
            for (headerField, headerValue) in headers
            {
                if let headerValueOnURLSession = urlSession.configuration.httpAdditionalHeaders?[headerField] as? String
                {
                    self.urlRequest.addValue(headerValueOnURLSession, forHTTPHeaderField: headerField)
                }
                
                urlRequest.addValue(headerValue,
                                    forHTTPHeaderField: headerField)
            }
        }
    }
}
