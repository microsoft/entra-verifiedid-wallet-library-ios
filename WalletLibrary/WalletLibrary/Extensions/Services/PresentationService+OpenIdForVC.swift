/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCServices

/**
 * An extension of the VCServices.PresentationService class.
 */
extension PresentationService: OpenIdForVCResolver, OpenIdForVCResponder {
    
    /// Fetches and validates the presentation request.
    func getRequest(url: String) async throws -> OpenIdRawRequest {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url)
        }()
    }
    
    /// Sends the presentation response container and if successful, returns void,
    /// If unsuccessful, throws an error.
    func send(response: VCEntities.PresentationResponseContainer) async throws -> Void {
        let _ = try await AsyncWrapper().wrap { () in
            self.send(response: response)
        }()
    }
}
