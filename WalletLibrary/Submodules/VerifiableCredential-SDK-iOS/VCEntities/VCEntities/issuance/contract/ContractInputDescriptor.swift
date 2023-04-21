/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct ContractInputDescriptor: Codable, Equatable {
    
    let id: String?
    let credentialIssuer: String
    let issuer: String
    let attestations: AttestationsDescriptor?
    
    init(id: String? = nil,
                credentialIssuer: String,
                issuer: String,
                attestations: AttestationsDescriptor? = nil) {
        self.id = id
        self.credentialIssuer = credentialIssuer
        self.issuer = issuer
        self.attestations = attestations
    }
}
