/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit
import VCEntities

@testable import VCServices

enum MockPresentationRequestValidatorError: Error {
    case isNotValid
}

class MockPresentationRequestValidator: RequestValidating {
    
    static var wasValidateCalled = false
    let isValid: Bool
    
    init (isValid: Bool = true) {
        self.isValid = isValid
    }
    
    func validate(request: PresentationRequestToken, usingKeys publicKeys: [IdentifierDocumentPublicKey]) throws {
        Self.wasValidateCalled = true
        if isValid {
            return
        } else {
            throw MockPresentationRequestValidatorError.isNotValid
        }
    }
    
    
}
