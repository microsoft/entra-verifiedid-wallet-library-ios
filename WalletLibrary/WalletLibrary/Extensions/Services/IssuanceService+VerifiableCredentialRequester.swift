/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCServices

/**
 * An extension of the VCServices.IssuanceService class.
 */
extension IssuanceService: VerifiableCredentialRequester {
    
    /// Sends the issuance response container and if successful, returns a Verifiable Credential.
    /// If unsuccessful, throws an error.
    func send<Request>(request: Request) async throws -> VerifiableCredential {
        
        guard let issuanceResponseContainer = request as? IssuanceResponseContainer else {
            throw VerifiedIdClientError.TODO(message: "add error")
        }
        
        let rawVerifiableCredential = try await AsyncWrapper().wrap { () in
            self.send(response: issuanceResponseContainer)
        }()
        
        let verifiableCredential = VerifiableCredential(raw: rawVerifiableCredential,
                                                        from: issuanceResponseContainer.contract)
        return verifiableCredential
    }
}
