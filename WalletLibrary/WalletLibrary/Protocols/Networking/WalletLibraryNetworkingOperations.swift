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
protocol WalletLibraryPostOperation: PostNetworkOperation
{
    init(requestBody: RequestBody,
         url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?)
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
