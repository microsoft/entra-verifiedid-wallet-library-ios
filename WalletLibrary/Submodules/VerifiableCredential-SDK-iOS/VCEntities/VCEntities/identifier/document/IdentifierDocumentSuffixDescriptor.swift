/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IdentifierDocumentSuffixDescriptor: Codable {
    let deltaHash: String
    let recoveryCommitment: String
}
