/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Visitor and builder used by RequestProcessors to serialize Requirements.
 */
class PresentationExchangeSerializer: RequestProcessorSerializing
{
    var submissionMap: [String: String] = [:]
    
    private let configuration: LibraryConfiguration
    
    private let vpFormatter: VerifiablePresentationFormatter
    
    init(libraryConfiguration: LibraryConfiguration,
         vpFormatter: VerifiablePresentationFormatter)
    {
        self.configuration = libraryConfiguration
        self.vpFormatter = vpFormatter
    }
    
    func serialize<T>(requirement: Requirement, verifiedIdSerializer: any VerifiedIdSerializing<T>) throws
    {
        guard let presentationExchangeRequirement = requirement as? PresentationExchangeVerifiedIdRequirement
        else {
            return
        }
        
        if let rawVC = try requirement.serialize(protocolSerializer: self,
                                                 verifiedIdSerializer: verifiedIdSerializer) as? String
        {

        }
    }
    
    
}
