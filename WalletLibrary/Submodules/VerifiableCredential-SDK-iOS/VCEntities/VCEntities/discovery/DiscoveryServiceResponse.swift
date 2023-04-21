/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct DiscoveryServiceResponse: Codable {
    let didDocument: IdentifierDocument
    
    init(didDocument: IdentifierDocument) {
        self.didDocument = didDocument
    }
}
