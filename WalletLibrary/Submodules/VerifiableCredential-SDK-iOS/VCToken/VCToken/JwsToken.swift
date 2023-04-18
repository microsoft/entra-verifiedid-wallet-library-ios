/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif

public enum JwsTokenError: Error {
    case unsupportedAlgorithm(name: String?)
}

public struct JwsToken<T: Claims> {
    
    public let headers: Header
    public let content: T
    public let protectedMessage: String
    public var rawValue: String?
    var signature: Signature?
    
    public init?(headers: Header,
                 content: T,
                 protectedMessage: String? = nil,
                 signature: Data? = nil,
                 rawValue: String? = nil) {
        
        self.headers = headers
        self.content = content
        self.signature = signature
        self.rawValue = rawValue
        
        if let message = protectedMessage {
            self.protectedMessage = message
        } else {
            do {
                self.protectedMessage = try JwsToken.createProtectedMessage(headers: headers, content: content)
            } catch {
                return nil
            }
        }
    }
    
    public init?(from encodedToken: String) {
        let decoder = JwsDecoder()
        do {
            self = try decoder.decode(T.self, token: encodedToken)
        } catch {
            // TODO log error
            return nil
        }
    }
    
    public init?(from encodedToken: Data) {
        guard let stringifiedToken = String(data: encodedToken, encoding: .utf8) else {
            return nil
        }
        self.init(from: stringifiedToken)
    }
    
    public func serialize() throws -> String {
        let encoder = JwsEncoder()
        return try encoder.encode(self)
    }
    
    public mutating func sign(using signer: TokenSigning, withSecret secret: VCCryptoSecret) throws {
        self.signature = try signer.sign(token: self, withSecret: secret)
    }
    
    public func verify(using verifier: TokenVerifying, withPublicKey key: JWK) throws -> Bool {
        return try verifier.verify(token: self, usingPublicKey: key)
    }
    
    /// Temporary: TODO: remove support for ECPublicJwk data model for JWK.
    public func verify(using verifier: TokenVerifying, withPublicKey key: ECPublicJwk) throws -> Bool {
        return try verify(using: verifier, withPublicKey: key.toJWK())
    }
    
    private static func createProtectedMessage(headers: Header, content: T) throws -> String {
        let encoder = JSONEncoder()
        let encodedHeader = try encoder.encode(headers).base64URLEncodedString()
        let encodedContent = try encoder.encode(content).base64URLEncodedString()
        return encodedHeader  + "." + encodedContent
    }
}

public typealias Signature = Data
