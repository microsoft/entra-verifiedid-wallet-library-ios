/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedIdEncoder: VerifiedIdEncoding {
    
    let mockEncode: ((VerifiedId) throws -> Data)
    
    init(mockEncode: @escaping ((VerifiedId) throws -> Data)) {
        self.mockEncode = mockEncode
    }
    
    func encode(verifiedId: VerifiedId) throws -> Data {
        return try mockEncode(verifiedId)
    }
}
