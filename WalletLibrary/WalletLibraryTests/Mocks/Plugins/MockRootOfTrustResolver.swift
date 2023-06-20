/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

struct MockRootOfTrustResolver: RootOfTrustResolver {

    let mockResolve: (String) throws -> LinkedDomainResult

    init(mockResolve: @escaping (String) throws -> LinkedDomainResult) {
        self.mockResolve = mockResolve
    }

    func resolve(did: String) async throws -> LinkedDomainResult {
        return try mockResolve(did)
    }
}
