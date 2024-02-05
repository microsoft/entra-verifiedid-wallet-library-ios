/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Networking Layer of the Wallet Library. All builtin networking operations will go through this layer.
 * Note: VC SDK legacy code still handles some networking operations.
 */
class WalletLibraryNetworking: LibraryNetworking
{
    private let urlSession: URLSession
    
    private let verifiedIdCorrelationHeader: VerifiedIdCorrelationHeader?
    
    private let logger: WalletLibraryLogger
    
    init(urlSession: URLSession, 
         logger: WalletLibraryLogger,
         verifiedIdCorrelationHeader: VerifiedIdCorrelationHeader?)
    {
        self.urlSession = urlSession
        self.logger = logger
        self.verifiedIdCorrelationHeader = verifiedIdCorrelationHeader
    }
    
    func resetCorrelationHeader()
    {
        verifiedIdCorrelationHeader?.reset()
    }
    
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
