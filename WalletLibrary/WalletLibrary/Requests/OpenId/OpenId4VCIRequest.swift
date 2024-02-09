/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


struct OpenId4VCIIDK
{
    let
}
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
         credentialMetadata: CredentialMetadata,
         credentialOffer: CredentialOffer,
         configuration: LibraryConfiguration) throws
    {
        self.style = style
        self.verifiedIdStyle = verifiedIdStyle
        self.requirement = try configuration.mapper.map(credentialOffer.grants)
        self.rootOfTrust = rootOfTrust
        self.credentialMetadata = credentialMetadata
        self.credentialOffer = credentialOffer
        self.configuration = configuration
    }
    
    func test() throws
    {
        let configurations = credentialMetadata.getCredentialConfigurations(ids: credentialOffer.credential_configuration_ids)
        for config in configurations
        {
            let test = try config.credential_definition?.display?.map { display in
                try configuration.mapper.map(display)
            }
        }
    }
    
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
