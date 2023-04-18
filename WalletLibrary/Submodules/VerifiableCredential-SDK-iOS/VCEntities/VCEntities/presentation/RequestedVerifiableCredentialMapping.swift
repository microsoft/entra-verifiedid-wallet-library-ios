/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Mapping between the request type and the chosen Verifiable Credential.
 */
public struct RequestedVerifiableCredentialMapping {
    
    /// Input descriptor id from the presentation request tied to verifiable credential requested.
    public let inputDescriptorId: String
    
    /// Verifiable Credential that fulfills this presentation request input descriptor id.
    public let vc: VerifiableCredential
    
    public init(id: String, verifiableCredential: VerifiableCredential) {
        self.inputDescriptorId = id
        self.vc = verifiableCredential
    }
}
