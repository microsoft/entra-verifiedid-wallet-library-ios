/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Issuance Request that conforms to the OpenId4VCI Protocol.
 */
class OpenId4VCIRequest: VerifiedIdIssuanceRequest
{
    public let style: RequesterStyle
    
    public let verifiedIdStyle: VerifiedIdStyle
    
    public let requirement: Requirement
    
    public let rootOfTrust: RootOfTrust
    
    private let credentialMetadata: CredentialMetadata
    
    private let credentialOffer: CredentialOffer
    
    private let configuration: LibraryConfiguration
    
    init(style: RequesterStyle,
         verifiedIdStyle: VerifiedIdStyle,
         rootOfTrust: RootOfTrust,
         requirement: Requirement,
         credentialMetadata: CredentialMetadata,
         credentialOffer: CredentialOffer,
         configuration: LibraryConfiguration)
    {
        self.style = style
        self.verifiedIdStyle = verifiedIdStyle
        self.rootOfTrust = rootOfTrust
        self.requirement = requirement
        self.credentialMetadata = credentialMetadata
        self.credentialOffer = credentialOffer
        self.configuration = configuration
    }
    
    // Only supports Access Token Requirement.
    func getRequirement(scope: String, authorizationServer: String) -> Requirement
    {
        return AccessTokenRequirement(configuration: authorizationServer,
                                      resourceId: "", // resource id is not needed.
                                      scope: scope)
    }
    
    func test(offer: CredentialOffer, metadata: CredentialMetadata) throws
    {
        let issuerName = metadata.display.first!.name
        let issuerStyle = VerifiedIdManifestIssuerStyle(name: issuerName)
        
        // Only support one right now.
        let credConf = metadata.getCredentialConfigurations(ids: offer.credential_configuration_ids)
        // Only support one right now.
        let definition = credConf.first!.credential_definition?.display?.first
        let verifiedIdStyle = try getVerifiedIdStyle(displayDefinition: definition,
                                                 issuerName: issuerName)
        
    }
    
    private func getVerifiedIdStyle(displayDefinition: LocalizedDisplayDefinition?,
                                    issuerName: String) throws -> VerifiedIdStyle
    {
        var verifiedIdLogo: VerifiedIdLogo? = nil
        if let logo = displayDefinition?.logo
        {
            verifiedIdLogo = try configuration.mapper.map(logo)
        }
        
        let style = BasicVerifiedIdStyle(name: displayDefinition?.name ?? "",
                                         issuer: issuerName,
                                         backgroundColor: displayDefinition?.background_color ?? "",
                                         textColor: displayDefinition?.text_color ?? "",
                                         description: "",
                                         logo: verifiedIdLogo)
        
        return style
    }
    
//    func test() throws
//    {
//        let configurations = credentialMetadata.getCredentialConfigurations(ids: credentialOffer.credential_configuration_ids)
//        for config in configurations
//        {
//            let test = try config.credential_definition?.display?.map { display in
//                try configuration.mapper.map(display)
//            }
//        }
//    }
    
    public func complete() async -> VerifiedIdResult<VerifiedId> 
    {
        let result: VerifiedIdResult<VerifiedId> = await VerifiedIdResult<VerifiedId>.getResult {
            throw OpenId4VCIHandlerError.Unimplemented
        }
        
        return result
    }
    
    func cancel(message: String?) async -> VerifiedIdResult<Void> 
    {
        let result = await VerifiedIdResult<VerifiedId>.getResult {
            throw OpenId4VCIHandlerError.Unimplemented
        }
        
        return result
    }
}
