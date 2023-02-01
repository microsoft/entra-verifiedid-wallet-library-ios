/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that describes a necessary piece of information to be included within an Issuance Request
 * to get a Verified ID from an issuer or within a Presentation Response to respond to a verifier.
 */
public protocol Requirement {
    /// Whether or not the requirement is required to fulfill request.
    var required: Bool { get }
    
    /// Validate the requirement, and throw if there is something invalid.
    func validate() throws
}
