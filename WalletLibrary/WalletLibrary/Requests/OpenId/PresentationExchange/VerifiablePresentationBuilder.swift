/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of building a Verifiable Presentation in JWT format.
 * (Protocol used to help with mocking in tests)
 */
protocol VerifiablePresentationBuilding
{
    func canInclude(partialInputDescriptor: PartialInputDescriptor) -> Bool
    
    func add(partialInputDescriptor: PartialInputDescriptor)
    
    func buildInputDescriptors() -> [InputDescriptorMapping]
    
    func buildVerifiablePresentation(audience: String,
                                     nonce: String,
                                     identifier: String,
                                     signingKey: KeyContainer) throws -> VerifiablePresentation
}

/**
 * Builds a Verifiable Presentation in JWT format.
 */
class VerifiablePresentationBuilder: VerifiablePresentationBuilding
{
    private let index: Int
    
    private var partialInputDescriptors: [PartialInputDescriptor]
    
    private let formatter: VerifiablePresentationFormatter
    
    init(index: Int,
         formatter: VerifiablePresentationFormatter = VerifiablePresentationFormatter())
    {
        self.index = index
        self.formatter = formatter
        partialInputDescriptors = []
    }
    
    func canInclude(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        return partialInputDescriptors.reduce(true) { result, partial in
            result ? partial.isCompatibleWith(partialInputDescriptor: partialInputDescriptor) : result
        }
    }
    
    func add(partialInputDescriptor: PartialInputDescriptor)
    {
        partialInputDescriptors.append(partialInputDescriptor)
    }
    
    func buildInputDescriptors() -> [InputDescriptorMapping]
    {
        let descriptors = partialInputDescriptors.enumerated().map { (vcIndex, partialInputDescriptor) in
            partialInputDescriptor.buildInputDescriptor(vcIndex: vcIndex,
                                                        vpIndex: index)
        }
        return descriptors
    }
    
    func buildVerifiablePresentation(audience: String,
                                     nonce: String,
                                     identifier: String,
                                     signingKey: KeyContainer) throws -> VerifiablePresentation
    {
        let rawVcsInGroup = partialInputDescriptors.map { $0.serializedVerifiedId }
        return try formatter.format(rawVCs: rawVcsInGroup,
                                    audience: audience,
                                    nonce: nonce,
                                    identifier: identifier,
                                    signingKey: signingKey)
    }
}
