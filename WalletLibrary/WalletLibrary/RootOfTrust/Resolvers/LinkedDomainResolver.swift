/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utilities such as logger, mapper, httpclient (post private preview) that are configured in builder and
 * all of library will use.
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
    
    func resolve(using identifier: Any) async throws -> RootOfTrust
    {
        guard let identifier = identifier as? IdentifierDocument else
        {
            throw VerifiedIdError(message: "", code: "")
        }
        
        let linkedDomain = try await linkedDomainService.validateLinkedDomain(from: identifier)
        return try configuration.mapper.map(linkedDomain)
    }
}
