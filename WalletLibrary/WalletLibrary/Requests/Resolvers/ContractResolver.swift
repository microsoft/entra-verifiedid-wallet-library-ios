/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Resolves a raw Open Id request from a URL input.
 */
struct ContractResolver: RequestResolving {
    
    private let contractScheme = "https"
    
    private let msContractResolver: MicrosoftContractResolver
    
    private let configuration: LibraryConfiguration
    
    init(msContractResolver: MicrosoftContractResolver, configuration: LibraryConfiguration) {
        self.msContractResolver = msContractResolver
        self.configuration = configuration
    }
    
    /// Whether or not the request handler given request handler can handle the resolved raw request.
    func canResolve(using handler: any RequestHandling) -> Bool {
        
        guard handler is OpenIdRequestHandler else {
            return false
        }
        
        return true
    }
    
    /// Whether or not the resolver can resolve input given.
    func canResolve(input: VerifiedIdRequestInput) -> Bool {
        
        guard let input = input as? VerifiedIdRequestURL else {
            return false
        }
        
        /// TODO: figure out what differentiates a contract from another https url.
        if input.url.scheme == contractScheme {
            return true
        }
        
        return false
    }
    
    /// Resolve raw request from input given.
    func resolve(input: VerifiedIdRequestInput) async throws -> any RawContract {
        
        guard let input = input as? VerifiedIdRequestURL else {
            throw OpenIdURLRequestResolverError.unsupportedVerifiedIdRequestInputWith(type: String(describing: type(of: input)))
        }
        
        return try await msContractResolver.getRequest(url: input.url.absoluteString)
    }
}

protocol MicrosoftContractResolver {
    
    func getRequest(url: String) async throws -> any RawContract
}

protocol RawContract: Mappable where T == VerifiedIdRequestContent { }
