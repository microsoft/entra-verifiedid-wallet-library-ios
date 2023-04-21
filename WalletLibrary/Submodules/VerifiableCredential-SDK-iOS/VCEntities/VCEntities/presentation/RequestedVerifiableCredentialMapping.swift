/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Mapping between the request type and the chosen Verifiable Credential.
 */
struct RequestedVerifiableCredentialMapping {
    
    /// Input descriptor id from the presentation request tied to verifiable credential requested.
    let inputDescriptorId: String
    
    /// Verifiable Credential that fulfills this presentation request input descriptor id.
    let vc: VerifiableCredential
    
    init(id: String, verifiableCredential: VerifiableCredential) {
        self.inputDescriptorId = id
        self.vc = verifiableCredential
    }
}
