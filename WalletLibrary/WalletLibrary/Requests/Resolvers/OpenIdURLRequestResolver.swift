/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
    func resolve(input: VerifiedIdRequestInput) async throws -> Any {
        
        guard let input = input as? VerifiedIdRequestURL else {
            throw OpenIdURLRequestResolverError.unsupportedVerifiedIdRequestInputWith(type: String(describing: type(of: input)))
        }
        
        // TODO: add support for Credential Offer and fall back to old Issuance flow.
        return try await openIdResolver.getRequest(url: input.url.absoluteString)
    }
}
