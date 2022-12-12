/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit

/**
 * Utility class for managing async strategy transformations.
 */
struct AsyncWrapper {
    
    /// Helper function that wraps a promiseKit call into an async function
    func wrap<T>(promiseFunc: @escaping () -> Promise<T>) -> (() async throws -> T) {
        let asyncFunc = { () in
            let result = try await withCheckedThrowingContinuation { continuation in
                promiseFunc().done { result in
                    continuation.resume(returning: result)
                }.catch { error in
                    continuation.resume(throwing: error)
                }
            }
            return result
        }
        return asyncFunc
    }
    
}
