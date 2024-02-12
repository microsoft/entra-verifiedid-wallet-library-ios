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
