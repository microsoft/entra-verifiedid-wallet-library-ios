/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The `OpenId4VCIRequest` class is designed to handle issuance requests in compliance with
 * the OpenId4VCI Protocol.
 *
 * The class extends the functionality of`VerifiedIdIssuanceRequest`l.
 */
class OpenId4VCIRequest: VerifiedIdIssuanceRequest
{
    /// The look and feel of the requester.
    public let style: RequesterStyle
    
    /// The look and feel of the verified id.
    public let verifiedIdStyle: VerifiedIdStyle
    
    /// The requirement needed to fulfill request.
    public let requirement: Requirement
    
    /// The root of trust results between the request and the source of the request.
    public let rootOfTrust: RootOfTrust
    
    /// The metadata about the credential being requested.
    private let credentialMetadata: CredentialMetadata
    
    /// The credential offer for the credential being requested.
    private let credentialOffer: CredentialOffer
    
    /// The library configuration.
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
    
    /// Completes the issuance process, returning the result of the issuance request.
    /// - Returns: A `VerifiedIdResult` containing the issued `VerifiedId` or an `VerifiedIdError`.
    public func complete() async -> VerifiedIdResult<VerifiedId>
    {
        let result: VerifiedIdResult<VerifiedId> = await VerifiedIdResult<VerifiedId>.getResult {
            let errorMessage = "Not implemented."
            throw VerifiedIdError(message: errorMessage, code: "")
        }
        
        return result
    }
    

    /// Cancels the issuance request, potentially with a custom message describing the reason for cancellation.
    public func cancel(message: String?) async -> VerifiedIdResult<Void>
    {
        let result = await VerifiedIdResult<VerifiedId>.getResult {
            let errorMessage = "Not implemented."
            throw VerifiedIdError(message: errorMessage, code: "")
        }
        
        return result
    }
}
