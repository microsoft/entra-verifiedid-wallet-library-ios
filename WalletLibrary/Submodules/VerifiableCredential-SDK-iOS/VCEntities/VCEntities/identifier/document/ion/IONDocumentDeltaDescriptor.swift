/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IONDocumentDeltaDescriptor: Codable {
    let updateCommitment: String
    let patches: [IONDocumentPatch]
}
