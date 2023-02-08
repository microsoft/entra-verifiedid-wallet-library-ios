/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary
import VCEntities

struct MockOpenIdForVCResolver: OpenIdForVCResolver {
    
    let mockGetRequestCallback: (String) -> OpenIdRawRequest
    
    init(mockGetRequestCallback: @escaping (String) -> OpenIdRawRequest) {
        self.mockGetRequestCallback = mockGetRequestCallback
    }
    
    func getRequest(url: String) async throws -> OpenIdRawRequest {
        return mockGetRequestCallback(url)
    }
}
