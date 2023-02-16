/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary
import VCEntities

class MockContractResolver: ManifestResolver, VerifiedIdRequester {
    
    let mockGetRequestCallback: ((String) throws -> any RawManifest)?
    
    init(mockGetRequestCallback: ((String) throws -> any RawManifest)? = nil) {
        self.mockGetRequestCallback = mockGetRequestCallback
    }
    
    func resolve(with url: String) async throws -> any RawManifest {
        return try mockGetRequestCallback?(url) ?? MockRawContract(id: "")
    }
    
    func send<Request>(request: Request) async throws -> RawVerifiedId {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
    
}

struct MockRawContract: RawManifest, Equatable {
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    func map(using mapper: WalletLibrary.Mapping) throws -> WalletLibrary.VerifiedIdRequestContent {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
