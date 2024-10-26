/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Verified ID Requirement with additional information required for Presentation Exchange RequestProcessor
 */
class PresentationExchangeVerifiedIdRequirement: VerifiedIdRequirement, PresentationExchangeRequirement
{
    
    var inputDescriptorId: String
    
    var format: String
    
    var exclusivePresentationWith: [String]?
    
    init(encrypted: Bool,
         required: Bool,
         types: [String],
         purpose: String?,
         issuanceOptions: [VerifiedIdRequestInput],
         id: String?,
         constraint: VerifiedIdConstraint,
         inputDescriptorId: String,
         format: String,
         exclusivePresentationWith: [String]?
    ) {
        self.inputDescriptorId = inputDescriptorId
        self.format = format
        self.exclusivePresentationWith = exclusivePresentationWith
        super.init(encrypted: encrypted,
                   required: required,
                   types: types,
                   purpose: purpose,
                   issuanceOptions: issuanceOptions,
                   id: id,
                   constraint: constraint)
    }
}
