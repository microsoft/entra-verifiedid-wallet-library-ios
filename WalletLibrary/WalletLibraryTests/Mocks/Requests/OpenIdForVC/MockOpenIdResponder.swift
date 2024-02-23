/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockOpenIdResponder: OpenIdResponder {
    
    let mockSend: ((RawPresentationResponse) async throws -> ())?
    
    init(mockSend: ((RawPresentationResponse) async throws -> ())? = nil) {
        self.mockSend = mockSend
    }
    
    func send(response: WalletLibrary.RawPresentationResponse, additionalHeaders: [String : String]?) async throws {
        try await self.mockSend?(response)
    }
}
