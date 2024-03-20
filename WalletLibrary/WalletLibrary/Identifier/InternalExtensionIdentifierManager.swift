/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Internal implementation for `ExtensionIdentifierManager` that handles Identifier operations used within Wallet Library Extensions.
 */
class InternalExtensionIdentifierManager: ExtensionIdentifierManager
{
    private let identifierManager: IdentifierManager
    
    private let configuration: LibraryConfiguration
    
    private let tokenSigner: TokenSigning
    
    internal struct Constants
    {
        static let SelfSignedType = "JWT"
        static let SelfSignedAlg = "ES256K"
        static let VCDataModelContext = "https://www.w3.org/2018/credentials/v1"
        static let VCDataModelType = "VerifiableCredential"
    }
    
    init(identifierManager: IdentifierManager,
         libraryConfiguration: LibraryConfiguration,
         tokenSigner: TokenSigning? = nil)
    {
        self.identifierManager = identifierManager
        self.configuration = libraryConfiguration
        self.tokenSigner = tokenSigner ?? Secp256k1Signer()
    }
    
    /// Given claims and types, append the claims and types to defaults, and create a self-signed Verified ID (Verifiable Credential).
    public func createEphemeralSelfSignedVerifiedId(claims: [String: String], 
                                                    types: [String]) throws -> VerifiedId
    {
        do
        {
            var vcTypes = [Constants.VCDataModelType]
            vcTypes.append(contentsOf: types)
            let vcDescriptor = VerifiableCredentialDescriptor(context: [Constants.VCDataModelContext],
                                                              type: vcTypes,
                                                              credentialSubject: claims)
            let identifier = try self.identifierManager.fetchOrCreateMasterIdentifier()
            guard let signingKey = identifier.didDocumentKeys.first else
            {
                throw IdentifierError.NoKeysInDocument()
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
                throw TokenValidationError.UnableToCreateToken()
            }
            
            try vcToken.sign(using: tokenSigner, withSecret: signingKey.keyReference)
            let verifiedId = try SelfSignedVerifiableCredential(raw: try vcToken.serialize())
            return verifiedId
        }
        catch
        {
            self.configuration.logger.logError(message: String(describing: error))
            throw IdentifierError.UnableToCreateSelfSignedVerifiedId(error: error)
        }
    }
    
    private func createTokenHeader(withKeyId keyId: String) -> Header
    {
        return Header(type: Constants.SelfSignedType,
                      algorithm: Constants.SelfSignedAlg,
                      encryptionMethod: nil,
                      jsonWebKey: nil,
                      keyId: keyId,
                      contentType: nil,
                      pbes2SaltInput: nil,
                      pbes2Count: nil)
    }
}
