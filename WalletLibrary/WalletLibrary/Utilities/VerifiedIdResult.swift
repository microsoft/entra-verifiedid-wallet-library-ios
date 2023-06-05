/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public typealias VerifiedIdResult<T> = Result<T, VerifiedIdError>

public extension VerifiedIdResult where Failure == VerifiedIdError {
        
        init(value: Success) {
            self = .success(value)
        }
        
        init(error: VerifiedIdError) {
            self = .failure(error)
        }
        
        var verifiedIdError: VerifiedIdError? {
            guard case let .failure(error) = self else { return nil }
            return error
        }
}

extension VerifiedIdResult {
    static func getResult<T>(callback: @escaping () async throws -> T) async -> VerifiedIdResult<T> {
        do {
            let result = try await callback()
            return VerifiedIdResult.success(result)
        } catch let error as VerifiedIdError {
            return error.result()
        } catch {
            return VerifiedIdErrors.UnspecifiedError(error: error).result()
        }
    }
}
