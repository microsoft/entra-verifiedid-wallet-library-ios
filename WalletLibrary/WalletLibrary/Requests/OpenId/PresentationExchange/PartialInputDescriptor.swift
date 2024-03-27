/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Represents a partial input descriptor for a Presentation Exchange Response.
 * This struct encapsulates the most of the essential information required for creating
 * a Presentation Exchange input descriptor.
 */
struct PartialInputDescriptor
{
    private enum Constants
    {
        static let JwtVc = "jwt_vc"
        static let JwtVp = "jwt_vp"
    }
    
    /// The serialized value of the Verified Id associated with this input descriptor.
    let serializedVerifiedId: String
    
    /// The ID from the request.
    private let inputDescriptorId: String
    
    /// The requirement fulfilled by this Input Descriptor.
    private let requirement: PresentationExchangeRequirement
    
    init(serializedVerifiedId: String, requirement: PresentationExchangeRequirement)
    {
        self.serializedVerifiedId = serializedVerifiedId
        self.inputDescriptorId = requirement.inputDescriptorId
        self.requirement = requirement
    }
    
    /// Determines if this partial input descriptor is compatible with another partial input descriptor.
    /// Compatibility is defined based on the exclusivity criteria specified in their presentation exchange
    /// requirements. If both input descriptors have exclusive presentation criteria that do not conflict
    /// with each other's identifier, they are considered compatible.
    /// This method will grow as we support more compatibility constraints such as Verified ID subject.
    func isCompatibleWith(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        let nonCompatIdsFromEntry = partialInputDescriptor.requirement.exclusivePresentationWith ?? []
        let nonCompatIdsFromSelf = requirement.exclusivePresentationWith ?? []
        let isEntryCompatWithId = !nonCompatIdsFromEntry.contains(where: { $0 == inputDescriptorId })
        let isSelfCompWithEntrysId = !nonCompatIdsFromSelf.contains(where: { $0 == partialInputDescriptor.inputDescriptorId })
        return isEntryCompatWithId && isSelfCompWithEntrysId
    }
    
    /// Builds the complete Input Descriptor for given vcIndex and vpIndex.
    func buildInputDescriptor(vcIndex: Int,
                              vpIndex: Int) -> InputDescriptorMapping
    {
        let vcPath = "$[\(vpIndex)].verifiableCredential[\(vcIndex)]"
        let nestedInputDesc = NestedInputDescriptorMapping(id: inputDescriptorId,
                                                           format: Constants.JwtVc,
                                                           path: vcPath)
        
        return InputDescriptorMapping(id: inputDescriptorId,
                                      format: Constants.JwtVp,
                                      path: "$[\(vpIndex)]",
                                      pathNested: nestedInputDesc)
    }
}
