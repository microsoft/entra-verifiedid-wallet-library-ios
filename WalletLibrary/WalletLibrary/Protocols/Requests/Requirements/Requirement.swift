/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that describes a necessary piece of information to be included within a Request.
 */
public protocol Requirement: AnyObject 
{
    /// Whether or not the requirement is required to fulfill request.
    var required: Bool { get }
    
    /// Validate the requirement, and throw if there is something invalid.
    func validate() -> VerifiedIdResult<Void>
}

extension [Requirement]
{
    func reduce() throws -> Requirement
    {
        if count == 1,
           let onlyRequirement = first
        {
            return onlyRequirement
        }
        else if count > 1
        {
            let groupRequirement = GroupRequirement(required: true,
                                                    requirements: self,
                                                    requirementOperator: .ALL)
            return groupRequirement
        }
        else
        {
            let errorMessage = "Grant types on Credential Offer not supported."
            throw OpenId4VCIValidationError.MalformedCredentialOffer(message: errorMessage)
        }
    }
}
