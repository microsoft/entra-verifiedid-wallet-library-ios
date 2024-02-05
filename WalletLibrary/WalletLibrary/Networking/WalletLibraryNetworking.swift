/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Networking Layer of the Wallet Library. All built-in networking operations will go through this layer.
 * Note: VC SDK legacy code still handles some networking operations.
 */
class WalletLibraryNetworking: LibraryNetworking
{
    /// URLSession instance used for making network requests.
    private let urlSession: URLSession
    
    /// Optional header for tracking request correlation, used for debugging and tracking request flows.
    private let verifiedIdCorrelationHeader: VerifiedIdCorrelationHeader?
    
    /// Logger instance for logging network request and response details.
    private let logger: WalletLibraryLogger
    
    init(urlSession: URLSession, 
         logger: WalletLibraryLogger,
         verifiedIdCorrelationHeader: VerifiedIdCorrelationHeader?)
    {
        self.urlSession = urlSession
        self.logger = logger
        self.verifiedIdCorrelationHeader = verifiedIdCorrelationHeader
    }
    
    /// Resets the correlation header to its initial state.
    /// This is useful for starting a new sequence of correlated requests.
    func resetCorrelationHeader()
    {
        verifiedIdCorrelationHeader?.reset()
    }
    
    /// Fetches data from a specified URL.
    /// - Parameters:
    ///   - url: The URL to fetch data from.
    ///   - type: The type of fetch operation to perform.
    ///   - additionalHeaders: Optional additional headers to include in the request.
    /// - Returns: The response body of the specified operation type.
    func fetch<Operation: WalletLibraryFetchOperation>(url: URL,
                                                       _ type: Operation.Type,
                                                       additionalHeaders: [String: String]? = nil) async throws -> Operation.ResponseBody
    {
        let operation = Operation(url: url,
                                  additionalHeaders: additionalHeaders,
                                  urlSession: urlSession,
                                  correlationVector: verifiedIdCorrelationHeader)
        return try await operation.fire()
    }
    
    /// Posts data to a specified URL.
    /// - Parameters:
    ///   - requestBody: The body of the request to post.
    ///   - url: The URL to post data to.
    ///   - type: The type of post operation to perform.
    ///   - additionalHeaders: Optional additional headers to include in the request.
    /// - Returns: The response body of the specified operation type.
    func post<Operation: WalletLibraryPostOperation>(requestBody: Operation.RequestBody,
                                                     url: URL,
                                                     _ type: Operation.Type,
                                                     additionalHeaders: [String: String]? = nil) async throws -> Operation.ResponseBody
    {
        let operation = Operation(requestBody: requestBody,
                                  url: url,
                                  additionalHeaders: additionalHeaders,
                                  urlSession: urlSession,
                                  correlationVector: verifiedIdCorrelationHeader)
        return try await operation.fire()
    }
}
