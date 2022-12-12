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
    
    /// An async function that gets and validates the presentation request
    func getRequest(url: String) async throws -> VCEntities.PresentationRequest {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url)
        }()
    }
}
