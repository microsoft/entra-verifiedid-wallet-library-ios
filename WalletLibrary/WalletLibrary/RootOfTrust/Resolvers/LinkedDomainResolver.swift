/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Responsible for resolving the Root of Trust through the Linked Domain.
 */
struct LinkedDomainResolver: RootOfTrustResolver
{
    private let linkedDomainService: LinkedDomainService
    
    private let configuration: LibraryConfiguration
    
    init(configuration: LibraryConfiguration)
    {
        self.configuration = configuration
        
        if let networking = configuration.networking as? WalletLibraryNetworking
        {
            self.linkedDomainService = LinkedDomainService(correlationVector: networking.correlationHeader,
                                                           urlSession: networking.urlSession)
        }
        else
        {
            self.linkedDomainService = LinkedDomainService(urlSession: URLSession.shared)
        }
    }
    
    /// Resolves the Root of Trust through Linked Domains.
    /// - Parameters:
    ///   - identifier: An identifier used to resolve the Linked Domains. This should be the `IdentifierDocument` in this case.
    func resolve(from identifier: AIdentifier) async throws -> RootOfTrust
    {
        guard let identifier = identifier as? AIdentifierDocument else
        {
            throw VerifiedIdError(message: "", code: "")
        }
        let linkedDomain = try await linkedDomainService.validateLinkedDomain(from: identifier.document)
        return try configuration.mapper.map(linkedDomain)
    }
}
