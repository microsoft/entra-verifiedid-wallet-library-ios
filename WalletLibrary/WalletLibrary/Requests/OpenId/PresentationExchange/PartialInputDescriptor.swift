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
    
    let serializedVerifiedId: String
    
    private let inputDescriptorId: String
    
    private let requirement: PresentationExchangeRequirement
    
    init(serializedVerifiedId: String, requirement: PresentationExchangeRequirement)
    {
        self.serializedVerifiedId = serializedVerifiedId
        self.inputDescriptorId = requirement.inputDescriptorId
        self.requirement = requirement
    }
    
    func isCompatibleWith(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        let nonCompatIdsFromEntry = partialInputDescriptor.requirement.exclusivePresentationWith ?? []
        let nonCompatIdsFromSelf = requirement.exclusivePresentationWith ?? []
        let isEntryCompatWithId = !nonCompatIdsFromEntry.contains(where: { $0 == inputDescriptorId })
        let isSelfCompWithEntrysId = !nonCompatIdsFromSelf.contains(where: { $0 == partialInputDescriptor.inputDescriptorId })
        return isEntryCompatWithId && isSelfCompWithEntrysId
    }
    
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
