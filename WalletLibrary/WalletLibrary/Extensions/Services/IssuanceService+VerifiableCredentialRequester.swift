/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCServices

enum IssuanceServiceVCRequesterError: Error {
    case unableToCastIssuanceResponseContainerFromType(String)
}
/**
 * An extension of the VCServices.IssuanceService class
 * that wraps send method with a generic send method that conforms to VerifiableCredentialRequester protocol.
 */
extension IssuanceService: VerifiableCredentialRequester {
    
    /// Sends the issuance response container and if successful, returns a Verifiable Credential.
    /// If unsuccessful, throws an error.
    func send<Request>(request: Request) async throws -> VerifiableCredential {
        
        guard let issuanceResponseContainer = request as? IssuanceResponseContainer else {
            let requestType = String(describing: request.self)
            throw IssuanceServiceVCRequesterError.unableToCastIssuanceResponseContainerFromType(requestType)
        }
        
        let rawVerifiableCredential = try await AsyncWrapper().wrap { () in
            self.send(response: issuanceResponseContainer)
        }()
        
        let verifiableCredential = try VerifiableCredential(raw: rawVerifiableCredential,
                                                            from: issuanceResponseContainer.contract)
        return verifiableCredential
    }
}
