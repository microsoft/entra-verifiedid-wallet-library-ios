/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct IdentifierDocumentServiceEndpoint: Codable, Equatable {
    public let origins: [String]?
    
    public init(origins: [String]?) {
        self.origins = origins
    }
}
