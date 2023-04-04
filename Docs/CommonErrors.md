# Common Wallet Library Errors

We return a Result object for every external interface that could have the potential to throw. Each public interface and what error could occur is outlined here.

## Outer Errors
### `VerifiedIdClient`

`createVerifiedIdRequest`
- `HttpError`:
    - Code
    - Retryable
- `UnsupportedProtocolError`
   - inner error with exact error
   - Retryable: false

`encode`
- `UnsupportedVerifiedIdTypeError`
    - Retryable: false

`decode`
- `InvalidRawDataError`
    - Retyable: false

### `VerifiedIdRequest`

`complete`
- `RequirementsNotMetError`, retryable: false
- `HttpError`
    - Code
    - Retryable

`cancel`
- `MissingStateError`
    - Retyable: false
- `MissingCallbackURLError`
    - Retyable: false
- `HttpError`:
    - Code
    - Retryable
   

### `Requirement`

`validate`
- `RequirementNotMetError`
- `VerifiedIdDoesNotMatchRequirementConstraintError`
  - inner error example: `invalidType`

`fulfill` (only for `VerifiedIdRequirement`)
- Same errors as `validate`

## Example of Errors in iOS
```swift
enum VerifiedIdClientError: Error {
    case HttpError(statusCode: Int, message: String, retryable: Bool, cause: Error?)
    case UnsupportedProtocolError(message: String, cause: Error?)
    case RequirementsNotMetError(message: String, cause: Error?)
}
```

## Example of Errors in Android 
```Kotlin
open class WalletLibraryException(message: String?, cause: Throwable?, retryable: Boolean): Exception(message, cause)

class HttpException(statusCode: Int, message: String, retryable: Boolean, cause: Throwable?): WalletLibraryException(message, cause, retryable)

class UnsupportedProtocolException(message: String, cause: Throwable, retryable: Boolean = false): WalletLibraryException(message, cause, retryable)

class RequirementsNotMetException(message: String, cause: Throwable?, retryable: Boolean = false): WalletLibraryException(message, cause, retryable)
```