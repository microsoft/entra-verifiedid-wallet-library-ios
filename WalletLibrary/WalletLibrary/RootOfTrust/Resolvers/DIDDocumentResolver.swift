/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Responsible for resolving Identifier Document using VC SDK DIDDocumentNetworkCalls.
 * TODO: shift to Wallet Library networking layer.
 */
struct DIDDocumentResolver: IdentifierDocumentResolving
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
    
    /// Resolves an Identifier Document for a given identifier.
    /// - Parameters:
    ///   - identifier: A string identifying the document to be resolved.
    func resolve(identifier: String) async throws -> IdentifierDocument
    {
        return try await identifierNetworkCalls.getDocument(from: identifier)
    }
}
