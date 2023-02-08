/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum OpenIdURLRequestResolverError: Error {
    case unsupportedVerifiedIdRequestInput(type: String)
}

/**
 * Handles a raw Open Id request and configures a VeriifedIdRequest object.
 */
struct OpenIdURLRequestResolver: RequestResolving {
    
    private let openIdResolver: OpenIdForVCResolver
    
    private let openIdScheme = "openid-vc"
    
    init(openIdResolver: OpenIdForVCResolver) {
        self.openIdResolver = openIdResolver
    }
    
    func canResolve(using handler: any RequestHandling) -> Bool {
        
        guard handler is OpenIdRequestHandler else {
            return false
        }
        
        return true
    }
    
    func canResolve(input: VerifiedIdRequestInput) -> Bool {
        
        guard let input = input as? VerifiedIdRequestURL else {
            return false
        }
        
        if input.url.scheme == openIdScheme {
            return true
        }
        
        return false
    }
    
    func resolve(input: VerifiedIdRequestInput) async throws -> OpenIdRawRequest {
        
        guard let input = input as? VerifiedIdRequestURL else {
            throw OpenIdURLRequestResolverError.unsupportedVerifiedIdRequestInput(type: String(describing: type(of: input)))
        }
        
        return try await openIdResolver.getRequest(url: input.url.absoluteString)
    }
}
