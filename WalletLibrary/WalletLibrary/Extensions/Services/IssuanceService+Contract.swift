/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCServices

/**
 * An extension of the VCServices.IssuanceService class.
 */
extension IssuanceService: ContractResolver {
    
    /// Fetches and validates the issuance request
    func getRequest(url: String) async throws -> any RawContract {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url)
        }()
    }
    
    /// Sends the issuance response container and if successful, returns void,
    /// If unsuccessful, throws an error.
    func send(response: VCEntities.IssuanceResponseContainer) async throws -> Void {
        let _ = try await AsyncWrapper().wrap { () in
            self.send(response: response)
        }()
    }
}
