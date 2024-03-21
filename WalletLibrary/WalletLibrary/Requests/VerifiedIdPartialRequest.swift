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
    
    init(requesterStyle: RequesterStyle, verifiedIdStyle: VerifiedIdStyle? = nil, requirement: Requirement, rootOfTrust: RootOfTrust) {
        self.requesterStyle = requesterStyle
        self.verifiedIdStyle = verifiedIdStyle
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
    }
}
