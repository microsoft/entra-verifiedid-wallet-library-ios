/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Input Descriptors are used by a Verifier to describe the information required of a Holder before an interaction can proceed
 *
 * @see [Presentation Exchange Spec](https://identity.foundation/presentation-exchange/#term:input-descriptor-object)
 */
public struct PresentationInputDescriptor: Codable, Equatable {

    /// Unique id of the input descriptor in the presentation definition.
    public let id: String?
    
    /// Describes the credentail type of the vc requested.
    public let schema: [InputDescriptorSchema]?
    
    /// If present, information describing how to get credential.
    public let issuanceMetadata: [IssuanceMetadata]?
    
    /// If present, its value SHOULD be a human-friendly name that describes what the target schema represents.
    public let name: String?
    
    /// If present, its value MUST be a string that describes the purpose for which the Claim's data is being requested.
    public let purpose: String?
    
    /// Describes constraints that the Holder must satisfy in response for presentation definition.
    public let constraints: PresentationExchangeConstraints?
    
    public init(id: String?,
                schema: [InputDescriptorSchema]?,
                issuanceMetadata: [IssuanceMetadata]?,
                name: String?,
                purpose: String?,
                constraints: PresentationExchangeConstraints?) {
        self.id = id
        self.schema = schema
        self.issuanceMetadata = issuanceMetadata
        self.name = name
        self.purpose = purpose
        self.constraints = constraints
    }
    
    enum CodingKeys: String, CodingKey {
        case issuanceMetadata = "issuance"
        case id, schema, name, purpose, constraints
    }
}
