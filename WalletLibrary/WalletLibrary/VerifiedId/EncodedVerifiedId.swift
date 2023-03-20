/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum SupportedVerifiedIdType: String, Codable {
    case VerifiableCredential = "VerifiableCredential"
}

struct EncodedVerifiedId: Codable {
    let type: SupportedVerifiedIdType

    let raw: Data
}
