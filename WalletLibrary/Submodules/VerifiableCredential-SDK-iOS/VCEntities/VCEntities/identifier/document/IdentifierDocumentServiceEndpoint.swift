/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IdentifierDocumentServiceEndpoint: Codable, Equatable {
    let origins: [String]?
    
    init(origins: [String]?) {
        self.origins = origins
    }
}
