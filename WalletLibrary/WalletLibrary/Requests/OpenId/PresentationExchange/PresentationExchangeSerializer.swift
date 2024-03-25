/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Visitor and builder used by RequestProcessors to serialize Requirements.
 */
class PresentationExchangeSerializer: RequestProcessorSerializing
{
    private let configuration: LibraryConfiguration
    
    private let vpFormatter: VerifiablePresentationFormatter
    
    private var vpGroupings: [VPGroup]
    
    private let state: String
    
    private let audience: String = ""
    
    private let nonce: String = ""
    
    private let definitionId: String = ""
    
    init(state: String,
         libraryConfiguration: LibraryConfiguration,
         vpFormatter: VerifiablePresentationFormatter)
    {
        self.state = state
        self.configuration = libraryConfiguration
        self.vpFormatter = vpFormatter
        self.vpGroupings = []
    }
    
    func serialize<T>(requirement: Requirement, verifiedIdSerializer: any VerifiedIdSerializing<T>) throws
    {
        guard let peRequirement = requirement as? PresentationExchangeRequirement else
        {
            return
        }
        
        if let rawVC = try requirement.serialize(protocolSerializer: self,
                                                 verifiedIdSerializer: verifiedIdSerializer) as? String
        {
            let entry = PartialSubmissionMapEntry(rawVC: rawVC,
                                                  peRequirement: peRequirement)
            addToVPGroupings(entry: entry)
        }
    }
    
    private func addToVPGroupings(entry: PartialSubmissionMapEntry)
    {
        for group in vpGroupings
        {
            if group.canInclude(entry: entry)
            {
                group.add(entry: entry)
                return
            }
        }
        
        let newGroup = VPGroup(index: vpGroupings.count)
        newGroup.add(entry: entry)
        vpGroupings.append(newGroup)
    }
    
    func build() throws -> PresentationResponse
    {
        let identifier = try configuration.identifierManager.fetchOrCreateMasterIdentifier()
        
        guard let firstKey = identifier.didDocumentKeys.first else
        {
            throw IdentifierError.NoKeysInDocument()
        }
        
        let idToken = try buildIdToken()
        let vpTokens = try buildVpTokens(identifier: identifier.longFormDid,
                                         signingKey: firstKey)
        return PresentationResponse(idToken: idToken,
                                    vpTokens: vpTokens,
                                    state: state)
    }
    
    private func buildIdToken() throws -> PresentationResponseToken
    {
        let inputDescriptors = vpGroupings.flatMap { $0.buildInputDescriptors() }
        let submission = PresentationSubmission(id: UUID().uuidString,
                                                definitionId: definitionId,
                                                inputDescriptorMap: inputDescriptors)
        
        throw VerifiedIdError(message: "", code: "")
    }
    
    private func buildVpTokens(identifier: String,
                               signingKey: KeyContainer) throws -> [VerifiablePresentation]
    {
        return try vpGroupings.map { vcGroup in
            let rawVcsInGroup = vcGroup.partials.map { $0.rawVC }
            return try vpFormatter.format(rawVCs: rawVcsInGroup,
                                          audience: audience,
                                          nonce: nonce,
                                          identifier: identifier,
                                          signingKey: signingKey)
        }
    }
}

struct PartialSubmissionMapEntry
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
    
    func isCompatibleWith(entry: PartialSubmissionMapEntry) -> Bool
    {
        let nonCompatIdsFromEntry = entry.peRequirement.exclusivePresentationWith ?? []
        let nonCompatIdsFromSelf = peRequirement.exclusivePresentationWith ?? []
        let isEntryCompatWithId = nonCompatIdsFromEntry.contains(where: { $0 == inputDescriptorId })
        let isSelfCompWithEntrysId = nonCompatIdsFromSelf.contains(where: { $0 == entry.inputDescriptorId })
        return isEntryCompatWithId || isSelfCompWithEntrysId
    }
}

class VPGroup
{
    private enum Constants
    {
        static let JwtVc = "jwt_vc"
        static let JwtVp = "jwt_vp"
    }
    
    let index: Int
    
    var partials: [PartialSubmissionMapEntry]
    
    init(index: Int)
    {
        self.index = index
        partials = []
    }
    
    func canInclude(entry: PartialSubmissionMapEntry) -> Bool
    {
        return partials.reduce(true) { result, partial in
            result ? partial.isCompatibleWith(entry: entry) : result
        }
    }
    
    func add(entry: PartialSubmissionMapEntry)
    {
        partials.append(entry)
    }
    
    func buildInputDescriptors() -> [InputDescriptorMapping]
    {
        let mappings = partials.enumerated().map { (vcIndex, entry) in
            self.build(vcIndex: vcIndex, entry: entry)
        }
        return mappings
    }
    
    private func build(vcIndex: Int, entry: PartialSubmissionMapEntry) -> InputDescriptorMapping
    {
        let vcPath = "$[\(index)].verifiableCredential[\(vcIndex)]"
        let nestedInputDescriptorMapping = NestedInputDescriptorMapping(id: entry.peRequirement.inputDescriptorId,
                                                                        format: Constants.JwtVc,
                                                                        path: vcPath)
        
        return InputDescriptorMapping(id: entry.peRequirement.inputDescriptorId,
                                      format: Constants.JwtVp,
                                      path: "$[\(index)]",
                                      pathNested: nestedInputDescriptorMapping)
    }
}
