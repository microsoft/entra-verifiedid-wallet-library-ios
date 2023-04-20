/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct DiscoveryServiceResponse: Codable {
    public let didDocument: IdentifierDocument
    
    public init(didDocument: IdentifierDocument) {
        self.didDocument = didDocument
    }
}
