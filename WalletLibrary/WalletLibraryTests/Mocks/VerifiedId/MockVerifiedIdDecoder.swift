/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedIdDecoder: VerifiedIdDecoding {

    let mockDecode: ((Data) throws -> VerifiedId)
    
    init(mockDecode: @escaping ((Data) throws -> VerifiedId)) {
        self.mockDecode = mockDecode
    }
    
    func decode(from data: Data) throws -> VerifiedId {
        return try mockDecode(data)
    }
}
