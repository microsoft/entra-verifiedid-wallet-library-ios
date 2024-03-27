/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Visitor and builder used by RequestProcessors to serialize Requirements.
 */
struct PartialInputDescriptor
{
    let rawVC: String
    
    let inputDescriptorId: String
    
    let peRequirement: PresentationExchangeRequirement
    
    init(rawVC: String, peRequirement: PresentationExchangeRequirement)
    {
        self.rawVC = rawVC
        self.inputDescriptorId = peRequirement.inputDescriptorId
        self.peRequirement = peRequirement
    }
    
    func isCompatibleWith(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        let nonCompatIdsFromEntry = partialInputDescriptor.peRequirement.exclusivePresentationWith ?? []
        let nonCompatIdsFromSelf = peRequirement.exclusivePresentationWith ?? []
        let isEntryCompatWithId = !nonCompatIdsFromEntry.contains(where: { $0 == inputDescriptorId })
        let isSelfCompWithEntrysId = !nonCompatIdsFromSelf.contains(where: { $0 == partialInputDescriptor.inputDescriptorId })
        return isEntryCompatWithId && isSelfCompWithEntrysId
    }
}
