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
    
    /**
     * Serializes the requirement into its raw format.
     * If this requirement is composed or an aggregate of other requirements,
     * MUST call the protocolSerializer's serialize function on all used requirements.
     * returns the raw format for a given SerializedFormat type (if it has output).
     */
    func serialize<T>(protocolSerializer: RequestProcessorSerializing,
                      verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T?
}

/**
 * An internal object that describes an access token requirement to be used a the BEARER token in an issuance request.
 */
protocol InternalAccessTokenRequirement: Requirement
{
    var accessToken: String? { get set }
}

/**
 * A helper method to be used to reduce a list of requirements into a `GroupRequirement`.
 */
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
            let errorMessage = "Requirement List is empty."
            throw VerifiedIdError(message: errorMessage, code: "unable_to_reduce_requirements")
        }
    }
}
