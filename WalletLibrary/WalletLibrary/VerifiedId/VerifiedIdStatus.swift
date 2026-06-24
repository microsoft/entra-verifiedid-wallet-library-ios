/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The status of a `VerifiedId`, returned by `VerifiedIdClient.checkVerifiedIdStatus(_:)`.
 *
 * Status is informational: the issuance/presentation server remains the authoritative enforcement
 * point. Treat `.unknown` as "could not determine" (fail-open), not as a failure.
 */
public enum VerifiedIdStatus: Equatable {

    /// Valid and not revoked, suspended, or expired.
    case valid

    /// The issuer has revoked this credential.
    case revoked

    /// The issuer has temporarily suspended this credential.
    case suspended

    /// The credential's `expiresOn` date has passed. Determined from the credential's own
    /// `expiresOn`, without fetching the issuer's status list (unlike `.revoked`/`.suspended`).
    case expired

    /// Status could not be determined — e.g. a network error, an unrecognised response, or a
    /// status-list reference using a method this SDK does not resolve.
    case unknown

    /// The credential carries no `credentialStatus`, so there is no status endpoint to check.
    case noStatusEndpoint
}
