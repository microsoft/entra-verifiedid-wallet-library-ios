/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Errors associated with the Open Id URL Request Resolver.
 */
enum OpenIdURLRequestResolverError: Error {
    case unsupportedVerifiedIdRequestInputWith(type: String)
}

/**
 * Resolves a raw Open Id request from a URL input.
 */
struct OpenIdURLRequestResolver: RequestResolving {
    
    private let openIdScheme = "openid-vc"
    
    private let openIdResolver: OpenIdForVCResolver
    
    private let configuration: LibraryConfiguration
    
    init(openIdResolver: OpenIdForVCResolver, configuration: LibraryConfiguration) {
        self.openIdResolver = openIdResolver
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
        
        if input.url.scheme == openIdScheme {
            return true
        }
        
        return false
    }
    
    /// Resolve raw request from input given.
    func resolve(input: VerifiedIdRequestInput) async throws -> any OpenIdRawRequest {
        
        guard let input = input as? VerifiedIdRequestURL else {
            throw OpenIdURLRequestResolverError.unsupportedVerifiedIdRequestInputWith(type: String(describing: type(of: input)))
        }
        
        return try await openIdResolver.getRequest(url: input.url.absoluteString)
    }
}
