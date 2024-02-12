/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Wallet Library Fetch Operation.
 */
protocol WalletLibraryFetchOperation: InternalNetworkOperation
{
    init(url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?)
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
         correlationVector: VerifiedIdCorrelationHeader?)
}

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

struct SimpleEncoder<T: Encodable>: Encoding
{
    func encode(value: T) throws -> Data
    {
        try JSONEncoder().encode(value)
    }
}

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
                urlRequest.addValue(headerValue, 
                                    forHTTPHeaderField: headerField)
            }
        }
    }
}
