/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Represents an incomplete mutable VerifiedID Request for RequestProcessorExtensions to modify.
 */
public class VerifiedIdPartialRequest
{
    /**
     * Display information for the requester
     */
    public var requesterStyle: RequesterStyle
    
    /**
     * Potential display information for the Verified ID being issued (if this is an issuance request)
     */
    public var verifiedIdStyle: VerifiedIdStyle?
    
    /**
     * Requirement for this request
     */
    public var requirement: Requirement
    
    /**
     * Root of trust resolved for this request
     */
    public var rootOfTrust: RootOfTrust
    
    init(requesterStyle: RequesterStyle, 
         verifiedIdStyle: VerifiedIdStyle? = nil,
         requirement: Requirement,
         rootOfTrust: RootOfTrust)
    {
        self.requesterStyle = requesterStyle
        self.verifiedIdStyle = verifiedIdStyle
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
    }
    
    /**
     * Replace `VerifiedIdRequirement` with given id in `Requirement` tree on the `VerifiedIdPartialRequest` using the
     * given transformer.
     * - Returns:
     *   - Requirement: the updated requirement or nil if not requirement was replaced.
     */
    public func replaceRequirement(id: String, how transformer: (VerifiedIdRequirement) -> Requirement) -> Requirement?
    {
        let (updatedRequirementTree, updatedRequirement) = replaceRequirement(id: id, from: requirement, transformer)
        requirement = updatedRequirementTree
        return updatedRequirement
    }
    
    /**
     * Remove a `VerifiedIdRequirement` with given id in `Requirement` tree on the `VerifiedIdPartialRequest`.
     * - Returns:
     *   - Bool: whether the requirement was successfully removed or not.
     */
    public func removeRequirement(id: String) -> Bool
    {
        guard let groupRequirement = requirement as? GroupRequirement else
        {
            return false
        }

        var wasRequirementRemoved = false
        for (index, req) in groupRequirement.requirements.enumerated()
        {
            if let verifiedIdRequirement = req as? VerifiedIdRequirement,
               verifiedIdRequirement.id == id
            {
                groupRequirement.requirements.remove(at: index)
                wasRequirementRemoved = true
            }
        }

        return wasRequirementRemoved
    }
    
    /// Recurse through the requirements and if there is a VerifiedIdRequirement with given id,
    /// replace requirement using given transformer and return replaced requirement. Return nil if not requirement
    /// matching those constraints was found.
    private func replaceRequirement(id: String,
                                    from oldRequirement: Requirement,
                                    _ transformer: (VerifiedIdRequirement) -> Requirement) -> (Requirement, Requirement?)
    {
        switch oldRequirement
        {
        case let groupRequirement as GroupRequirement:
            for (index, childRequirement) in groupRequirement.requirements.enumerated()
            {
                let (updatedReqTree, updatedReq) = replaceRequirement(id: id, from: childRequirement, transformer)
                if let updatedReq = updatedReq
                {
                    groupRequirement.requirements[index] = updatedReqTree
                    return (groupRequirement, updatedReq)
                }
            }
            
            return (oldRequirement, nil)
            
        case let verifiedIdRequirement as VerifiedIdRequirement:
            return replaceRequirement(id: id, from: verifiedIdRequirement, transformer)
        default:
            return (oldRequirement, nil)
        }
    }
    
    private func replaceRequirement(id: String,
                                    from oldRequirement: VerifiedIdRequirement,
                                    _ transformer: (VerifiedIdRequirement) -> Requirement) -> (Requirement, Requirement?)
    {
        if oldRequirement.id == id
        {
            let updatedRequirement = transformer(oldRequirement)
            return (updatedRequirement, updatedRequirement)
        }
        else
        {
            return (oldRequirement, nil)
        }
    }
}
