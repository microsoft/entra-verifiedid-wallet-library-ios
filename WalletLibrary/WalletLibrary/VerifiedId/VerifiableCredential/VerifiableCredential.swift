/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Verifiable Credential object contains the raw VC, and the contract that created the Verifiable Credential.
 * This object conforms to the Mappable protocol and maps VC claims and display contract to a Verified Id.
 */
struct VerifiableCredential: Mappable {
    
    let raw: VCEntities.VerifiableCredential
    
    let contract: Contract
    
    init(raw: VCEntities.VerifiableCredential, from contract: Contract) {
        self.raw = raw
        self.contract = contract
    }
    
    func map(using mapper: Mapping) throws -> VerifiedId {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
