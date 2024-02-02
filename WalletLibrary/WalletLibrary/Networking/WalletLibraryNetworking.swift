/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The constraints for issuance and display information of a credential,
 */
class WalletLibraryNetworking
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
    
    func fetch<Operation: WalletLibraryNetworkOperation>(request: URLRequest,
                                                         type: Operation.Type) async throws -> Operation.ResponseBody
    {
        let operation = Operation(urlSession: urlSession,
                                  urlRequest: request,
                                  correlationVector: verifiedIdCorrelationHeader)
        return try await operation.fire()
    }
}
