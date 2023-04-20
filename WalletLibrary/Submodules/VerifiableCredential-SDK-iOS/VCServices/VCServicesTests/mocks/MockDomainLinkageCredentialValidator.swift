/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit
import VCEntities

@testable import VCServices

enum MockDomainLinkageCredentialValidatorError: Error {
    case isNotValid
}

class MockDomainLinkageCredentialValidator: DomainLinkageCredentialValidating {

    static var wasValidateCalled = false
    let isValid: Bool
    
    init (isValid: Bool = true) {
        self.isValid = isValid
    }
    
    func validate(credential: DomainLinkageCredential, usingDocument document: IdentifierDocument, andSourceDomainUrl url: String) throws {
        Self.wasValidateCalled = true
        if isValid {
            return
        } else {
            throw MockPresentationRequestValidatorError.isNotValid
        }
    }
}
