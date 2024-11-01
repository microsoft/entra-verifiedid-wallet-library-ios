/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Internal implementation for `ExtensionIdentifierManager` that handles Identifier operations used within Wallet Library Extensions.
 */
class InternalExtensionIdentifierManager: ExtensionIdentifierManager
{
    private let configuration: LibraryConfiguration
    
    internal struct Constants
    {
        static let VCDataModelContext = "https://www.w3.org/2018/credentials/v1"
        static let VCDataModelType = "VerifiableCredential"
    }
    
    init(libraryConfiguration: LibraryConfiguration)
    {
        self.configuration = libraryConfiguration
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
            
            let identifier = try configuration.identifierFactory.getIdentifier()
            
            let tokenHeader = JwsHeaderFormatter().formatHeaders(identifier: identifier)
            
            let timeConstraints = TokenTimeConstraints(expiryInSeconds: 300) // 5 minutes
            let token = JwsToken<VCClaims>(headers: tokenHeader,
                                           content: VCClaims(jti: UUID().uuidString,
                                                             iss: identifier.id,
                                                             sub: identifier.id,
                                                             iat: timeConstraints.issuedAt,
                                                             exp: timeConstraints.expiration,
                                                             vc: vcDescriptor))
            
            guard var vcToken = token else
            {
                throw TokenValidationError.UnableToCreateToken(ofType: String(describing: VerifiableCredential.self))
            }
            
            try vcToken.sign(using: identifier)
            let verifiedId = try SelfSignedVerifiableCredential(raw: try vcToken.serialize())
            return verifiedId
        }
        catch
        {
            self.configuration.logger.logError(message: String(describing: error))
            throw IdentifierError.UnableToCreateSelfSignedVerifiedId(error: error)
        }
    }
}
