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
    
    func buildVerifiablePresentation(audience: String,
                                     nonce: String,
                                     identifier: HolderIdentifier) throws -> VerifiablePresentation
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
    
    /// Formats headers for a JWS token.
    private let headerFormatter: JwsHeaderFormatter
    
    init(index: Int,
         headerFormatter: JwsHeaderFormatter = JwsHeaderFormatter())
    {
        self.index = index
        self.headerFormatter = headerFormatter
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
    
    func buildVerifiablePresentation(audience: String,
                                     nonce: String,
                                     identifier: HolderIdentifier) throws -> VerifiablePresentation
    {
        let serializedVerifiedIds = partialInputDescriptors.map { $0.serializedVerifiedId }
        return try build(rawVCs: serializedVerifiedIds,
                         audience: audience,
                         nonce: nonce,
                         identifier: identifier)
    }
    
    private func build(rawVCs: [String],
                       audience: String,
                       nonce: String,
                       identifier: HolderIdentifier) throws -> VerifiablePresentation
    {
        let headers = headerFormatter.formatHeaders(identifier: identifier)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: 3000)
        let vpDescriptor = VerifiablePresentationDescriptor(verifiableCredential: rawVCs)
        
        let vpClaims = VerifiablePresentationClaims(vpId: UUID().uuidString,
                                                    verifiablePresentation: vpDescriptor,
                                                    issuerOfVp: identifier.id,
                                                    audience: audience,
                                                    iat: timeConstraints.issuedAt,
                                                    nbf: timeConstraints.issuedAt,
                                                    exp: timeConstraints.expiration,
                                                    nonce: nonce)
        
        guard var token = JwsToken(headers: headers, content: vpClaims) else
        {
            throw TokenValidationError.UnableToCreateToken(ofType: String(describing: VerifiablePresentation.self))
        }
        
        try token.sign(using: identifier)
        return token
    }
}
