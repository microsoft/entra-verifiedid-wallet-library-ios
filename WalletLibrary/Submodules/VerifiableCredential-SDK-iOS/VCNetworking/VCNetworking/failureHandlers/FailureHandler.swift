/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation

protocol FailureHandler {
    func onFailure(data: Data, response: HTTPURLResponse) throws -> VerifiedIdError
}
