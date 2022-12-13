/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCServices
import VCEntities

/**
 * An Extension of the VCServices.PresentationService class.
 */
extension PresentationService: PresentationServiceable {
    
    /// Fetches and validates the presentation request.
    func getRequest(url: String) async throws -> VCEntities.PresentationRequest {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url)
        }()
    }
    
    /// Sends the presentation response container and if successful, returns void, if unsuccessful, throws an error.
    func send(response: PresentationResponseContainer) async throws -> Void {
        let _ = try await AsyncWrapper().wrap { () in
            self.send(response: response)
        }()
    }
}
