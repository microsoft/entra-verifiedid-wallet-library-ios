/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCServices
import VCEntities

struct OpenIdURLRequestResolver: RequestResolver {
    
    let presentationService: PresentationService
    
    init(presentationService: PresentationService) {
        self.presentationService = presentationService
    }
    
    func canResolve(using handler: RequestHandler) -> Bool {
        
        guard handler is OpenIdRequestHandler else {
            return false
        }
        
        return true
    }
    
    func canResolve(input: VerifiedIdClientInput) -> Bool {
        
        guard let input = input as? URLInput else {
            return false
        }
        
        if input.url.scheme == "openid-vc" {
            return true
        }
        
        return false
    }
    
    func resolve(input: VerifiedIdClientInput, using params: [AdditionalRequestParams]) async throws -> RawRequest {
        
        guard let input = input as? URLInput else {
            throw VerifiedIdClientError.TODO(message: "input not urlinput")
        }
        
        let request = try await presentationService.getRequest(url: input.url.absoluteString)
        
        return OpenIdURLRequest(raw: Data(), presentationRequest: request)
    }
}

struct OpenIdURLRequest: RawRequest {
    let raw: Data
    
    let presentationRequest: PresentationRequest
}
