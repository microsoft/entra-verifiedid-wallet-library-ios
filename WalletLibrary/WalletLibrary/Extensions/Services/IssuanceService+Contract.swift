/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCServices

/**
 * An extension of the VCServices.IssuanceService class.
 */
extension IssuanceService: ManifestResolver, VerifiedIdRequester {
    
    /// Fetches and validates the issuance request.
    func resolve(with url: String) async throws -> any RawManifest {
        return try await AsyncWrapper().wrap { () in
            self.getRequest(usingUrl: url)
        }()
    }
    
    /// Sends the issuance response container and if successful, returns Verifiable Credential.
    /// If unsuccessful, throws an error.
    func send<Request>(request: Request) async throws -> RawVerifiedId {
        
        guard let issuanceResponseContainer = request as? IssuanceResponseContainer else {
            throw VerifiedIdClientError.TODO(message: "add error")
        }
        
        let verifiableCredential = try await AsyncWrapper().wrap { () in
            self.send(response: issuanceResponseContainer)
        }()
        
        let rawValue = try verifiableCredential.serialize()
        return RawVerifiedId(raw: rawValue)
    }
}

struct RawVerifiedId {
    let raw: String
}
