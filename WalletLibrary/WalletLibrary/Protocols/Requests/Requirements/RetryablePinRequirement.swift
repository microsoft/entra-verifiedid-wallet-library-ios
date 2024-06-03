/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that describes a retryable pin requirement needed for a request.
 */
public protocol RetryablePinRequirement: Requirement
{
    func fulfill(with pin: String) async -> VerifiedIdResult<Void>
}
