/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCCrypto
import VCToken

@testable import VCEntities

class DomainLinkageCredentialValidatorTests: XCTestCase {
    
    private struct Mocks {
        static let credentialSubjectDid = "did:test"
    }
    
    let verifier: TokenVerifying = MockTokenVerifier(isTokenValid: true)
    let mockPublicKey = ECPublicJwk(x: "x", y: "y", keyId: "keyId")
    let mockDomain = "test.com"
    var mockIdentifierDocument: IdentifierDocument!
    
    override func setUpWithError() throws {
        let mockDidPublicKey = IdentifierDocumentPublicKey(id: "#keyId",
                                                       type: "Typetest",
                                                       controller: "controllerTest",
                                                       publicKeyJwk: mockPublicKey,
                                                       purposes: ["purpose"])
        mockIdentifierDocument = IdentifierDocument(service: [],
                                                    verificationMethod: [mockDidPublicKey],
                                                    authentication: [],
                                                    id: Mocks.credentialSubjectDid)
    }
    
    override func tearDownWithError() throws {
        MockTokenVerifier.wasVerifyCalled = false
    }
    
    func testShouldBeValid() throws {
        let validator = DomainLinkageCredentialValidator(verifier: verifier)
        let claims = createMockDomainLinkageCredentialClaims()
        let keyId = Mocks.credentialSubjectDid + "#keyId"
        if let credential = DomainLinkageCredential(headers: Header(keyId: keyId),content: claims) {
            
            try validator.validate(credential: credential,
                                   usingDocument: mockIdentifierDocument,
                                   andSourceDomainUrl: mockDomain)
            
            XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testInvalidSignature() throws {
        let verifier: TokenVerifying = MockTokenVerifier(isTokenValid: false)
        let validator = DomainLinkageCredentialValidator(verifier: verifier)
        let claims = createMockDomainLinkageCredentialClaims()
        if let credential = DomainLinkageCredential(headers: Header(keyId: "did:test#keyId"),content: claims) {
            
            XCTAssertThrowsError(try validator.validate(credential: credential,
                                                        usingDocument: mockIdentifierDocument,
                                                         andSourceDomainUrl: mockDomain)) { error in
                
                XCTAssertEqual(error as? DomainLinkageCredentialValidatorError,
                               DomainLinkageCredentialValidatorError.invalidSignature)
                
            }
            XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testInvalidDomainLinkageCredentialIssuer() throws {
        let wrongIssuer = "did:test:wrongCredentialIssuer"
        let validator = DomainLinkageCredentialValidator(verifier: verifier)
        let claims = createMockDomainLinkageCredentialClaims(issuerDid: wrongIssuer)
        if let credential = DomainLinkageCredential(headers: Header(keyId: "did:test#keyId"),content: claims) {
            
            XCTAssertThrowsError(try validator.validate(credential: credential,
                                                        usingDocument: mockIdentifierDocument,
                                                         andSourceDomainUrl: mockDomain)) { error in
                
                XCTAssertEqual(error as? DomainLinkageCredentialValidatorError,
                               DomainLinkageCredentialValidatorError.doNotMatch(credentialSubject: Mocks.credentialSubjectDid,
                                                                                tokenIssuer: wrongIssuer))
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testInvalidDomainLinkageCredentialSubject() throws {
        let wrongSubject = "did:test:notMatching"
        let validator = DomainLinkageCredentialValidator(verifier: verifier)
        let claims = createMockDomainLinkageCredentialClaims(subjectDid: wrongSubject)
        if let credential = DomainLinkageCredential(headers: Header(keyId: "did:test#keyId"),content: claims) {
            
            
            XCTAssertThrowsError(try validator.validate(credential: credential,
                                                        usingDocument: mockIdentifierDocument,
                                                         andSourceDomainUrl: mockDomain)) { error in
                
                XCTAssertEqual(error as? DomainLinkageCredentialValidatorError,
                               DomainLinkageCredentialValidatorError.doNotMatch(credentialSubject: Mocks.credentialSubjectDid,
                                                                                tokenSubject: wrongSubject))
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testIdentifierDocumentAndCredentialSubjectDoNotMatch() throws {
        
        let wrongIdentifierDocumentDid = "did:test:notMatching"
        let mockDidPublicKey = IdentifierDocumentPublicKey(id: "#keyId",
                                                       type: "Typetest",
                                                       controller: "controllerTest",
                                                       publicKeyJwk: mockPublicKey,
                                                       purposes: ["purpose"])
        let identifierDocument = IdentifierDocument(service: [],
                                                    verificationMethod: [mockDidPublicKey],
                                                    authentication: [],
                                                    id: wrongIdentifierDocumentDid)
        
        let validator = DomainLinkageCredentialValidator(verifier: verifier)
        let claims = createMockDomainLinkageCredentialClaims()
        if let credential = DomainLinkageCredential(headers: Header(keyId: "did:test#keyId"),content: claims) {
            
            XCTAssertThrowsError(try validator.validate(credential: credential,
                                                        usingDocument: identifierDocument,
                                                         andSourceDomainUrl: mockDomain)) { error in
                
                XCTAssertEqual(error as? DomainLinkageCredentialValidatorError,
                               DomainLinkageCredentialValidatorError.doNotMatch(credentialSubject: Mocks.credentialSubjectDid,
                                                                                identifierDocumentDid: wrongIdentifierDocumentDid))
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testDomainUrlsDoNotMatch() throws {
        let wrongDomainUrl = "did:test:notMatching"
        let validator = DomainLinkageCredentialValidator(verifier: verifier)
        let claims = createMockDomainLinkageCredentialClaims()
        if let credential = DomainLinkageCredential(headers: Header(keyId: "did:test#keyId"),content: claims) {
            
            XCTAssertThrowsError(try validator.validate(credential: credential,
                                                        usingDocument: mockIdentifierDocument,
                                                         andSourceDomainUrl: wrongDomainUrl)) { error in
                
                XCTAssertEqual(error as? DomainLinkageCredentialValidatorError,
                               DomainLinkageCredentialValidatorError.doNotMatch(sourceDomainUrl: wrongDomainUrl,
                                                                                wellknownDocumentDomainUrl: mockDomain))
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testDocumentIdAndCredentialKeyIdDoNotMatch() throws {
        let validator = DomainLinkageCredentialValidator(verifier: verifier)
        let claims = createMockDomainLinkageCredentialClaims()
        let keyId = "KeyIdThatDoesntMatch#keyId"
        if let credential = DomainLinkageCredential(headers: Header(keyId: keyId),content: claims) {
            
            XCTAssertThrowsError(try validator.validate(credential: credential,
                                   usingDocument: mockIdentifierDocument,
                                                        andSourceDomainUrl: mockDomain)) { error in
                
                XCTAssertEqual(error as? DomainLinkageCredentialValidatorError,
                               DomainLinkageCredentialValidatorError.doNotMatch(linkedDomainCredentialKeyId: keyId,
                                                                                identifierDocumentDid: Mocks.credentialSubjectDid))
            }
            
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    private func createMockDomainLinkageCredentialClaims(issuerDid: String = Mocks.credentialSubjectDid,
                                                 subjectDid: String = Mocks.credentialSubjectDid) -> DomainLinkageCredentialClaims {
        let subject = DomainLinkageCredentialSubject(did: Mocks.credentialSubjectDid,
                                                     domainUrl: mockDomain)
        let content = DomainLinkageCredentialContent(context: ["context"],
                                                     issuer: issuerDid,
                                                     issuanceDate: "mock date",
                                                     expirationDate: "mock exp",
                                                     type: ["mock type"],
                                                     credentialSubject: subject)
        return DomainLinkageCredentialClaims(subject: subjectDid,
                                                   issuer: issuerDid,
                                                   notValidBefore: 42353,
                                                   verifiableCredential: content)
    }

}
