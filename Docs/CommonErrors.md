# Common Wallet Library Errors

We return a Result object for every external interface that could have the potential to throw. Each public interface and what error could occur is outlined here.

## `VerifiedIdClient`

`createVerifiedIdRequest`
- `unableToResolveRequest`
   - inner error example: `httpError`
- `unableToHandleRequest`
   - inner error example: `invalidSignature`

`encode`
- `unableToEncodeVerifiedId`
  - inner error example: `unsupportedVerifiedIdType`

`decode`
- `unableToDecodeVerifiedId`
  - inner error example: `unableToDecodeRawData`

## `VerifiedIdRequest`

`complete`
- `invalidRequirements`
- `unableToComplete`
  - inner error example: `httpError`

`cancel`
- `unableToSendRequestResult`
  - inner error example: `httpError`
   

## `Requirement`

`validate`
- `requirementHasNotBeFulfilled`
- `verifiedIdDoesNotMatchConstraint`
  - inner error example: `invalidType`

`fulfill` (only for `VerifiedIdRequirement`)
- Same errors as `validate`

