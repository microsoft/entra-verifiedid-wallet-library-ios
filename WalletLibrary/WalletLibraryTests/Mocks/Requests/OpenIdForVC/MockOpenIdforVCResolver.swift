/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary
import VCEntities

struct MockOpenIdForVCResolver: OpenIdForVCResolver {
    
    enum MockOpenIdForVCResolverError: Error {
        case nilCallback
    }
    
    let mockGetRequestCallback: ((String) -> OpenIdRawRequest)?
    
    init(mockGetRequestCallback: ((String) -> OpenIdRawRequest)? = nil) {
        self.mockGetRequestCallback = mockGetRequestCallback
    }
    
    func getRequest(url: String) async throws -> OpenIdRawRequest {
        
        guard let mockGetRequestCallback = mockGetRequestCallback else {
            throw MockOpenIdForVCResolverError.nilCallback
        }
        return mockGetRequestCallback(url)
    }
}
