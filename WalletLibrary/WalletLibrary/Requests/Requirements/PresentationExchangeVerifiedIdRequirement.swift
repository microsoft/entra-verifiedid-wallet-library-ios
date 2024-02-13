/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Verified ID Requirement with additional information required for Presentation Exchange RequestProcessor
 */
public class PresentationExchangeVerifiedIdRequirement: VerifiedIdRequirement {
    
    var inputDescriptorId: String
    
    var format: PresentationExchangeVerifiedIdFormat = .JWT_VC
    
    var exclusivePresentationWith: [String]?
    
    var encodedCredential: String?
    
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
    
    override public func fulfill(with verifiedId: VerifiedId) -> VerifiedIdResult<Void> {
        let fulfillResult = super.fulfill(with: verifiedId)
        switch (fulfillResult) {
        case Result.success():
            switch (verifiedId) {
            case let vcVerifiedId as VCVerifiedId where verifiedId is VCVerifiedId:
                guard let rawCredential = vcVerifiedId.raw.rawValue else {
                    return VerifiedIdResult.failure(VerifiedIdError(message: "No Data in Verified ID", code: "NoData"))
                }
                self.encodedCredential = rawCredential
                return fulfillResult
            default:
                return VerifiedIdResult.failure(VerifiedIdError(message: "Unsupported Verified ID Format", code: "NotSupported"))
            }
        default:
            return fulfillResult
        }
    }
}

enum PresentationExchangeVerifiedIdFormat {
    case JWT_VC
}
