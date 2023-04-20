/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct ContractInputDescriptor: Codable, Equatable {
    
    public let id: String?
    public let credentialIssuer: String
    public let issuer: String
    public let attestations: AttestationsDescriptor?
    
    public init(id: String? = nil,
                credentialIssuer: String,
                issuer: String,
                attestations: AttestationsDescriptor? = nil) {
        self.id = id
        self.credentialIssuer = credentialIssuer
        self.issuer = issuer
        self.attestations = attestations
    }
}
