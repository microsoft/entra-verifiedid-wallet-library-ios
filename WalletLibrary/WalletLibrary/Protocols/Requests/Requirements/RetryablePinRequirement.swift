/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Describes attributes of a requirement for a user input pin.
 */
public protocol UserInputPinRequirement: Requirement
{
    /// If the requirement is required or not.
    var required: Bool { get }
    
    /// The length of the pin to display.
    var length: Int { get }
    
    /// The type of the pin such as alphanumeric or numeric.
    var type: String { get }
}

/**
 * An object that describes a retryable pin requirement needed for a request.
 */
public protocol RetryablePinRequirement: UserInputPinRequirement
{
    func fulfill(with pin: String) async -> VerifiedIdResult<Void>
}
