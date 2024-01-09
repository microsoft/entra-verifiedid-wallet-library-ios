/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdPresentationRequestError: Error {
    case CancelPresentationRequestIsUnsupported
    case IdentifierDoesNotContainKeys
    case UnableToCreateSelfSignedVC
}

/**
 * Presentation Requst that is Open Id specific.
 */
class OpenIdPresentationRequest: VerifiedIdPresentationRequest {

    /// The look and feel of the requester.
    let style: RequesterStyle
    
    /// The requirement needed to fulfill request.
    let requirement: Requirement
    
    /// The root of trust results between the request and the source of the request.
    let rootOfTrust: RootOfTrust
    
    /// The DID of the verifier
    let authority: String
    
    let nonce: String?
    
    private let rawRequest: any OpenIdRawRequest
    
    private let responder: OpenIdResponder
    
    private let configuration: LibraryConfiguration
    
    init(content: PresentationRequestContent,
         rawRequest: any OpenIdRawRequest,
         openIdResponder: OpenIdResponder,
         configuration: LibraryConfiguration) {
        
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.rawRequest = rawRequest
        self.authority = rawRequest.authority
        self.nonce = rawRequest.nonce
        self.responder = openIdResponder
        self.configuration = configuration
        
        addSelfSigningAbilityToRequirements(requirement: requirement)
    }

    private func addSelfSigningAbilityToRequirements(requirement: Requirement)
    {
        switch requirement 
        {
        case let groupRequirement as GroupRequirement:
            for req in groupRequirement.requirements
            {
                addSelfSigningAbilityToRequirements(requirement: req)
            }
        case let verifiedIdRequirement as VerifiedIdRequirement:
            verifiedIdRequirement.signSelfSignedVC = signSelfSignedVC
        default:
            return
        }
    }
    
    /// Whether or not the request is satisfied on client side.
    func isSatisfied() -> Bool {
        do {
            try requirement.validate().get()
            return true
        } catch {
            /// TODO: log error.
            return false
        }
    }
    
    /// Completes the request and returns a Result object containing void if successful, and an error if not successful.
    func complete() async -> VerifiedIdResult<Void> {
        return await VerifiedIdResult<Void>.getResult {
            var response = try PresentationResponseContainer(rawRequest: self.rawRequest)
            try response.add(requirement: self.requirement)
            try await self.responder.send(response: response)
        }
    }
    
    /// Cancel the request with an optional message.
    func cancel(message: String?) async -> VerifiedIdResult<Void> {
        return VerifiedIdError(message: message ?? "User Canceled.", code: VerifiedIdErrors.ErrorCode.UserCanceled).result()
    }
}

extension OpenIdPresentationRequest
{
    internal struct Constants
    {
        static let FaceCheckSchema = "LivenessCheck"
        static let selfSignedType = "JWT"
        static let selfSignedAlg = "ES256K"
        static let vcDataModelContext = "https://www.w3.org/2018/credentials/v1"
        static let vcDataModelType = "VerifiableCredential"
    }
    
    private func signSelfSignedVC(claims: [String: String], types: [String]) throws -> VerifiedId
    {
        let vcDescriptor = VerifiableCredentialDescriptor(context: [Constants.vcDataModelContext],
                                                          type: types,
                                                          credentialSubject: claims)
        let identifier = try configuration.identifierManager.fetchOrCreateMasterIdentifier()
        guard let signingKey = identifier.didDocumentKeys.first else
        {
            throw VerifiedIdPresentationRequestError.IdentifierDoesNotContainKeys
        }
        
        let tokenHeader = createTokenHeader(withKeyId: identifier.did + "#" + signingKey.keyId)
        
        let now = round(Date().timeIntervalSince1970 * 1000)
        let expiry = round(Date().addingTimeInterval(TimeInterval(5 * 60)).timeIntervalSince1970 * 1000) // 5 minutes
        let token = JwsToken<VCClaims>(headers: tokenHeader,
                                       content: VCClaims(jti: UUID().uuidString,
                                                         iss: identifier.did,
                                                         sub: identifier.did,
                                                         iat: now,
                                                         exp: expiry,
                                                         vc: vcDescriptor))
        
        guard var vcToken = token else
        {
            throw VerifiedIdPresentationRequestError.UnableToCreateSelfSignedVC
        }
        
        let signer = Secp256k1Signer()
        try vcToken.sign(using: signer, withSecret: signingKey.keyReference)
        vcToken.rawValue = try vcToken.serialize()
        let verifiedId = try VCVerifiedId(raw: vcToken)
        return verifiedId
    }
    
    private func createTokenHeader(withKeyId keyId: String) -> Header
    {
        return Header(type: Constants.selfSignedType,
                      algorithm: Constants.selfSignedAlg,
                      encryptionMethod: nil,
                      jsonWebKey: nil,
                      keyId: keyId,
                      contentType: nil,
                      pbes2SaltInput: nil,
                      pbes2Count: nil)
    }
}
