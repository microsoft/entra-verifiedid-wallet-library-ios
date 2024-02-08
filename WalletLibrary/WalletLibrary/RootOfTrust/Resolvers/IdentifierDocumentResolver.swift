/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utilities such as logger, mapper, httpclient (post private preview) that are configured in builder and
 * all of library will use.
 */
struct IdentifierDocumentResolver
{
    private let identifierNetworkCalls: DIDDocumentNetworkCalls
    
    init(configuration: LibraryConfiguration)
    {
        if let networking = configuration.networking as? WalletLibraryNetworking
        {
            self.identifierNetworkCalls = DIDDocumentNetworkCalls(correlationVector: networking.correlationHeader,
                                                                  urlSession: networking.urlSession)
        }
        else
        {
            self.identifierNetworkCalls = DIDDocumentNetworkCalls(urlSession: URLSession.shared)
        }
    }
    
    func resolve(identifier: String) async throws -> IdentifierDocument
    {
        return try await identifierNetworkCalls.getDocument(from: identifier)
    }
}
