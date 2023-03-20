/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockOpenIdResponder: OpenIdResponder {
    
    let mockSend: ((PresentationResponse) async throws -> ())?
    
    init(mockSend: ((PresentationResponse) async throws -> ())? = nil) {
        self.mockSend = mockSend
    }
    func send(response: PresentationResponse) async throws {
        try await self.mockSend?(response)
    }
}
