/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public protocol ExchangeRequestFormatting {
    func format(request: ExchangeRequestContainer) throws -> ExchangeRequest
}

public class ExchangeRequestFormatter: ExchangeRequestFormatting {
    
    let signer: TokenSigning
    let sdkLog: VCSDKLog
    let headerFormatter = JwsHeaderFormatter()
    
    public init(signer: TokenSigning = Secp256k1Signer(),
                sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.signer = signer
        self.sdkLog = sdkLog
    }
    
    public func format(request: ExchangeRequestContainer) throws -> ExchangeRequest {
        
        guard let signingKey = request.currentOwnerIdentifier.didDocumentKeys.first else {
            throw FormatterError.noSigningKeyFound
        }
        
        sdkLog.logDebug(message: "Creating Exchange Request")
        
        return try createToken(request: request, andSignWith: signingKey)
    }
    
    private func createToken(request: ExchangeRequestContainer, andSignWith signingKey: KeyContainer) throws -> ExchangeRequest {
        
        let headers = headerFormatter.formatHeaders(usingIdentifier: request.currentOwnerIdentifier, andSigningKey: signingKey)
        let tokenContents = try formatClaims(request: request, andSigningKey: signingKey)
        
        guard var token = JwsToken(headers: headers, content: tokenContents) else {
            throw FormatterError.unableToFormToken
        }
        
        try token.sign(using: self.signer, withSecret: signingKey.keyReference)
        return token
    }
    
    private func formatClaims(request: ExchangeRequestContainer, andSigningKey key: KeyContainer) throws -> ExchangeRequestClaims {
        
        let publicKey = try signer.getPublicJwk(from: key.keyReference, withKeyId: key.keyId)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: 5)
        
        guard let exchangeableVC = request.exchangeableVerifiableCredential.rawValue,
              let did = request.exchangeableVerifiableCredential.content.sub else {
            throw FormatterError.unableToGetRawValueOfVerifiableCredential
        }
        
        return ExchangeRequestClaims(publicKeyThumbprint: try publicKey.getThumbprint(),
                                     audience: request.audience,
                                      did: did,
                                      publicJwk: publicKey,
                                      jti: UUID().uuidString,
                                      iat: timeConstraints.issuedAt,
                                      exp: timeConstraints.expiration,
                                      exchangeableVc: exchangeableVC,
                                      recipientDid: request.newOwnerDid)
    }
}
