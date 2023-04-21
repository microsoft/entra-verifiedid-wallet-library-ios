/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct VerifiablePresentationDescriptor: Codable {
    
    let context: [String]
    
    let type: [String]
    
    let verifiableCredential: [String]
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type, verifiableCredential
    }
}
