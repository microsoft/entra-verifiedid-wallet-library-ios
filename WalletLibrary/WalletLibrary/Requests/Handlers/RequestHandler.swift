/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCServices

enum RequestHandlerError: Error {
    case Test(message: String, error: Error)
}

/**
 *
 */
class RequestHandler: RequestHandling {
    
    private let presentationService: PresentationServiceable
    
    
    init(presentationService: PresentationServiceable = PresentationService()) {
        self.presentationService = presentationService
    }
    
    func handle(requestUri: URL) async throws -> Request {
        do {
            let request = try await presentationService.getRequest(url: requestUri.absoluteString)
            print(request)
            return IssuanceRequest(requester: request.content.nonce!,
                                   credentialIssuerMetadata: [],
                                   contracts: [],
                                   pinRequirements: nil,
                                   credentialFormats: [],
                                   state: "")
            
        } catch {
            throw RequestHandlerError.Test(message: "Unable to handle request", error: error)
        }
    }
    
}
