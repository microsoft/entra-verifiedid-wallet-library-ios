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
    /// Determines if a given PartialInputDescriptor can be included in the Verifiable Presentation.
    func canInclude(partialInputDescriptor: PartialInputDescriptor) -> Bool
    
    /// Adds a PartialInputDescriptor to the collection of descriptors to be included in the Verifiable Presentation.
    func add(partialInputDescriptor: PartialInputDescriptor)
    
    /// Builds the Verifiable Presentation using the added `PartialInputDescriptor`s and additional parameters.
    func buildInputDescriptors() -> [InputDescriptorMapping]
    
    /// Builds the Verifiable Presentation using the added `PartialInputDescriptor`s and additional parameters.
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
    /// Index identifying the position of the Verifiable Presentation in a collection.
    private let index: Int
    
    /// A collection of PartialInputDescriptors that will be included in the Verifiable Presentation.
    private var partialInputDescriptors: [PartialInputDescriptor]
    
    /// The formatter used to generate the final Verifiable Presentation.
    private let formatter: VerifiablePresentationFormatter
    
    init(index: Int,
         formatter: VerifiablePresentationFormatter = VerifiablePresentationFormatter())
    {
        self.index = index
        self.formatter = formatter
        partialInputDescriptors = []
    }
    
    /// Determines if a given PartialInputDescriptor can be included in the Verifiable Presentation.
    func canInclude(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        return partialInputDescriptors.reduce(true) { result, partial in
            result ? partial.isCompatibleWith(partialInputDescriptor: partialInputDescriptor) : result
        }
    }
    
    /// Adds a PartialInputDescriptor to the collection of descriptors to be included in the Verifiable Presentation.
    func add(partialInputDescriptor: PartialInputDescriptor)
    {
        partialInputDescriptors.append(partialInputDescriptor)
    }
    
    /// Builds and returns an array of `InputDescriptorMapping`s from the added `PartialInputDescriptor`s.
    func buildInputDescriptors() -> [InputDescriptorMapping]
    {
        let descriptors = partialInputDescriptors.enumerated().map { (vcIndex, partialInputDescriptor) in
            partialInputDescriptor.buildInputDescriptor(vcIndex: vcIndex,
                                                        vpIndex: index)
        }
        return descriptors
    }
    
    /// Builds the Verifiable Presentation using the added `PartialInputDescriptor`s and additional parameters.
    func buildVerifiablePresentation(audience: String,
                                     nonce: String,
                                     identifier: String,
                                     signingKey: KeyContainer) throws -> VerifiablePresentation
    {
        let serializedVerifiedIds = partialInputDescriptors.map { $0.serializedVerifiedId }
        return try formatter.format(rawVCs: serializedVerifiedIds,
                                    audience: audience,
                                    nonce: nonce,
                                    identifier: identifier,
                                    signingKey: signingKey)
    }
}
