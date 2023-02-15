/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockContractResolver: ContractResolver {
    
    let mockGetRequestCallback: ((String) throws -> any RawContract)?
    
    init(mockGetRequestCallback: ((String) throws -> any RawContract)? = nil) {
        self.mockGetRequestCallback = mockGetRequestCallback
    }
    
    func getRequest(url: String) async throws -> any RawContract {
        return try mockGetRequestCallback?(url) ?? MockRawContract(id: "")
    }
    
}

struct MockRawContract: RawContract, Equatable {
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    func map(using mapper: WalletLibrary.Mapping) throws -> WalletLibrary.VerifiedIdRequestContent {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
