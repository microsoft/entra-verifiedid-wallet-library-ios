/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Visitor and builder used by RequestProcessors to serialize Requirements.
 */
class VerifiablePresentationBuilder
{
    private enum Constants
    {
        static let JwtVc = "jwt_vc"
        static let JwtVp = "jwt_vp"
    }
    
    let index: Int
    
    var partials: [PartialInputDescriptor]
    
    init(index: Int)
    {
        self.index = index
        partials = []
    }
    
    func canInclude(entry: PartialInputDescriptor) -> Bool
    {
        return partials.reduce(true) { result, partial in
            result ? partial.isCompatibleWith(entry: entry) : result
        }
    }
    
    func add(entry: PartialInputDescriptor)
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
    
    private func build(vcIndex: Int, entry: PartialInputDescriptor) -> InputDescriptorMapping
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
