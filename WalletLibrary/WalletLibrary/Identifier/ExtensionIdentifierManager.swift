/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public class ExtensionIdentifierManager
{
    let identifierManager: IdentifierManager
    
    internal struct Constants
    {
        static let SelfSignedType = "JWT"
        static let SelfSignedAlg = "ES256K"
        static let VCDataModelContext = "https://www.w3.org/2018/credentials/v1"
        static let VCDataModelType = "VerifiableCredential"
    }
    
    init(identifierManager: IdentifierManager) {
        self.identifierManager = identifierManager
    }
    
    public func createEphemeralSelfSignedVerifiedId(claims: [String: String], types: [String]) -> VerifiedId?
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
                return nil
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
                return nil
            }
            
            let signer = Secp256k1Signer()
            try vcToken.sign(using: signer, withSecret: signingKey.keyReference)
            vcToken.rawValue = try vcToken.serialize()
            let verifiedId = try VCVerifiedId(raw: vcToken, from: <#Contract#>)
            return verifiedId
        }
        catch
        {
            return nil
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
