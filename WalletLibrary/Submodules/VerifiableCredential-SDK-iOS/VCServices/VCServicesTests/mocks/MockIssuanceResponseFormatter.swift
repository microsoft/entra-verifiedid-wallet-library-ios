/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

enum MockIssuanceResponseFormatterError: Error {
    case doNotWantToResolveRealObject
}

class MockIssuanceResponseFormatter: IssuanceResponseFormatting {
    
    static var wasFormatCalled = false
    let shouldSucceed: Bool
    
    init(shouldSucceed: Bool) {
        self.shouldSucceed = shouldSucceed
    }
    
    func format(response: IssuanceResponseContainer, usingIdentifier identifier: Identifier) throws -> IssuanceResponse {
        Self.wasFormatCalled = true
        if (shouldSucceed) {
            return IssuanceResponse(from: VCServicesTestData.issuanceResponse.rawValue)!
        } else {
            throw MockIssuanceResponseFormatterError.doNotWantToResolveRealObject
        }
    }
}
