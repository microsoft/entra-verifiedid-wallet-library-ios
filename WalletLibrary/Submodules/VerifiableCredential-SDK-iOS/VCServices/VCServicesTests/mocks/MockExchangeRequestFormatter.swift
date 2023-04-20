/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit
import VCEntities

@testable import VCServices

enum MockExchangeResponseFormatterError: Error {
    case doNotWantToResolveRealObject
}

class MockExchangeRequestFormatter: ExchangeRequestFormatting {
    
    static var wasFormatCalled = false
    let shouldSucceed: Bool
    
    init(shouldSucceed: Bool) {
        self.shouldSucceed = shouldSucceed
    }
    
    func format(request: ExchangeRequestContainer) throws -> ExchangeRequest {
        Self.wasFormatCalled = true
        if (shouldSucceed) {
            return ExchangeRequest(from: TestData.exchangeRequest.rawValue)!
        } else {
            throw MockExchangeResponseFormatterError.doNotWantToResolveRealObject
        }
    }
}
