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
    
    private let presentationService: PresentationServiceable
    
    private let openIdScheme = "openid-vc"
    
    init(presentationService: PresentationServiceable) {
        self.presentationService = presentationService
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
    
    func resolve(input: VerifiedIdRequestInput) async throws -> PresentationRequest {
        
        guard let input = input as? VerifiedIdRequestURL else {
            throw OpenIdURLRequestResolverError.unsupportedVerifiedIdRequestInput(type: String(describing: input))
        }
        
        return try await presentationService.getRequest(url: input.url.absoluteString)
    }
}
