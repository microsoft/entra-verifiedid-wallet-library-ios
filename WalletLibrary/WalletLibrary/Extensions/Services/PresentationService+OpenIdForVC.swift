/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCServices

enum PresentationServiceError: Error {
    case unableToCastOpenIdForVCResponseToPresentationResponseContainer
}

/**
 * An extension of the VCServices.PresentationService class.
 */
extension PresentationService: OpenIdForVCResolver, OpenIdForVCResponder {
    
    /// Fetches and validates the presentation request.
    func getRequest(url: String) async throws -> any OpenIdRawRequest {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url)
        }()
    }
    
    /// Sends the presentation response container and if successful, returns void,
    /// If unsuccessful, throws an error.
    func send(response: PresentationResponse) async throws -> Void {
        
        guard let presentationResponseContainer = response as? PresentationResponseContainer else {
            throw PresentationServiceError.unableToCastOpenIdForVCResponseToPresentationResponseContainer
        }
        
        let _ = try await AsyncWrapper().wrap { () in
            self.send(response: presentationResponseContainer)
        }()
    }
}

protocol PresentationResponse {
    mutating func add(requirement: Requirement) throws
}


