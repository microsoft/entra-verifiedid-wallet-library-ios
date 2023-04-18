/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import PromiseKit

final class NoRetry: RetryHandler {

    func onRetry<ResponseBody>(closure : @escaping () -> Promise<ResponseBody>) -> Promise<ResponseBody> {
        return closure()
    }
}
