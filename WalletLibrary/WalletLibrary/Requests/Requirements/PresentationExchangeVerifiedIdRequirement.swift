/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Verified ID Requirement with additional information required for Presentation Exchange RequestProcessor
 */
public class PresentationExchangeVerifiedIdRequirement: VerifiedIdRequirement, PresentationExchangeRequirement {
    
    var inputDescriptorId: String
    
    var format: PresentationExchangeVerifiedIdFormat = .JWT_VC
    
    var exclusivePresentationWith: [String]?
    
    init(encrypted: Bool,
                  required: Bool,
                  types: [String],
                  purpose: String?,
                  issuanceOptions: [VerifiedIdRequestInput],
                  id: String?,
                  constraint: VerifiedIdConstraint,
                  inputDescriptorId: String,
                  format: PresentationExchangeVerifiedIdFormat,
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
