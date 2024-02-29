/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Visitor and builder used by RequestProcessors to serialize Requirements.
 */
public protocol RequestProcessorSerializing
{
    /**
     * Processes and serializes this requirement using Requirement.serialize
     * note: Requirement.Serialize must be called and is expected to call this method on any child requirements before returning
     */
    func serialize<T>(requirement: Requirement, verifiedIdSerializer: any VerifiedIdSerializing<T>) -> Void
}
