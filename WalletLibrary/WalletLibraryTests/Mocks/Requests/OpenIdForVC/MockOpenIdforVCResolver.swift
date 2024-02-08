/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockOpenIdForVCResolver: OpenIdForVCResolver {
    
    enum MockOpenIdForVCResolverError: Error {
        case nilCallback
    }
    
    private let mockGetRequestCallback: ((String) -> any OpenIdRawRequest)?
    
    init(mockGetRequestCallback: ((String) -> any OpenIdRawRequest)? = nil) {
        self.mockGetRequestCallback = mockGetRequestCallback
    }
    
    func getRequest(url: String) async throws -> any OpenIdRawRequest {
        
        guard let mockGetRequestCallback = mockGetRequestCallback else {
            throw MockOpenIdForVCResolverError.nilCallback
        }
        return mockGetRequestCallback(url)
    }
    
    func validateRequest(data: Data) async throws -> any OpenIdRawRequest
    {
        return mockGetRequestCallback?("") ?? MockOpenIdRawRequest(raw: nil)
    }
}
