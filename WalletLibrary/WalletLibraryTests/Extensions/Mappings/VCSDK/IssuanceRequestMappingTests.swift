/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

class IssuanceRequestMappingTests: XCTestCase {
    
    private let mapper = Mapper()
    
    private let expectedRootOfTrustSource = "source2034"
    
    private lazy var mockVerifiedRootOfTrust = {
        return RootOfTrust(verified: true, source: expectedRootOfTrustSource)
    }()
    
    private lazy var mockVerifiedLinkedDomainResult = {
        return LinkedDomainResult.linkedDomainVerified(domainUrl: expectedRootOfTrustSource)
    }()
    
    func testSuccessfulMappingWithVerifiedDomain() throws {
        
        let signedContract = setUpSignedContract(usingMockContract: true)
        
        let (input, expectedResult) = try setUpInput(signedContract: signedContract)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testSuccessfulMappingWithUnverifiedDomain() throws {
        
        let rootOfTrust = RootOfTrust(verified: false, source: expectedRootOfTrustSource)
        let linkedDomainResult = LinkedDomainResult.linkedDomainUnverified(domainUrl: expectedRootOfTrustSource)
        let signedContract = setUpSignedContract(usingMockContract: true)
        
        let (input, expectedResult) = try setUpInput(rootOfTrust: rootOfTrust,
                                                     linkedDomainResult: linkedDomainResult,
                                                     signedContract: signedContract)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testSuccessfulMappingWithMissingDomain() throws {
        
        let rootOfTrust = RootOfTrust(verified: false, source: nil)
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let signedContract = setUpSignedContract(usingMockContract: true)
        
        let (input, expectedResult) = try setUpInput(rootOfTrust: rootOfTrust,
                                                     linkedDomainResult: linkedDomainResult,
                                                     signedContract: signedContract)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMissingRawToken() throws {
        
        let rootOfTrust = RootOfTrust(verified: true, source: expectedRootOfTrustSource)
        let linkedDomainResult = LinkedDomainResult.linkedDomainVerified(domainUrl: expectedRootOfTrustSource)
        
        let signedContract = setUpSignedContract(rawValue: nil)
        
        let (input, _) = try setUpInput(rootOfTrust: rootOfTrust,
                                        linkedDomainResult: linkedDomainResult,
                                        signedContract: signedContract)

        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "token.rawValue", in: String(describing: VCEntities.IssuanceRequest.self)))
        }
    }
    
    func testMissingAttestations() throws {
        
        let rootOfTrust = RootOfTrust(verified: true, source: expectedRootOfTrustSource)
        let linkedDomainResult = LinkedDomainResult.linkedDomainVerified(domainUrl: expectedRootOfTrustSource)
        
        let signedContract = setUpSignedContract(containsAttestations: false)
        
        let (input, _) = try setUpInput(rootOfTrust: rootOfTrust,
                                        linkedDomainResult: linkedDomainResult,
                                        signedContract: signedContract)

        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "content.input.attestations",
                                               in: String(describing: VCEntities.IssuanceRequest.self)))
        }
    }
    
    private func setUpInput(rootOfTrust: RootOfTrust? = nil,
                            linkedDomainResult: LinkedDomainResult? = nil,
                            signedContract: SignedContract) throws -> (VCEntities.IssuanceRequest, WalletLibrary.Contract) {
        
        let expectedRootOfTrust = rootOfTrust ?? mockVerifiedRootOfTrust
        let expectedLinkedDomainResult = linkedDomainResult ?? mockVerifiedLinkedDomainResult

        let input = VCEntities.IssuanceRequest(from: signedContract, linkedDomainResult: expectedLinkedDomainResult)
        
        var accessTokenRequirements: [AccessTokenRequirement] = []
        let mockAccessTokenDescriptor = signedContract.content.input.attestations?.accessTokens?.first
        if let accessTokenDescriptor = mockAccessTokenDescriptor {
            let mockAccessTokenRequirement = try mapper.map(accessTokenDescriptor)
            accessTokenRequirements = [mockAccessTokenRequirement]
        }
        
        
        let expectedResult = Contract(rootOfTrust: expectedRootOfTrust,
                                      verifiedIdRequirements: [],
                                      idTokenRequirements: [],
                                      accessTokenRequirements: accessTokenRequirements,
                                      selfAttestedClaimRequirements: nil,
                                      raw: testSignedContract)
        
        return (input, expectedResult)
    }
    
    private func setUpSignedContract(usingMockContract: Bool = false,
                                     containsAttestations: Bool = true,
                                     rawValue: String? = "expectedRawValue") -> SignedContract {
        
        if usingMockContract {
            return SignedContract(from: testSignedContract)!
        }
        
        var attestations: AttestationsDescriptor? = nil
        if containsAttestations {
            let mockAccessTokenDescriptor = AccessTokenDescriptor(configuration: "mockConfig",
                                                                  resourceId: "mockResourceId",
                                                                  oboScope: "mockScope")
            attestations = AttestationsDescriptor(accessTokens: [mockAccessTokenDescriptor])
        }
        
        let contractInputDescriptor = ContractInputDescriptor(credentialIssuer: "mockIssuer",
                                                              issuer: "mockIssuer",
                                                              attestations: attestations)
        let contract = VCEntities.Contract(id: "mockId",
                                           display: getMockDisplayDescriptor(),
                                           input: contractInputDescriptor)
        let signedContract = SignedContract(headers: Header(), content: contract, rawValue: rawValue)!
        return signedContract
    }
    
    private func getMockDisplayDescriptor() -> DisplayDescriptor {
        
        let mockCardDescriptor = CardDisplayDescriptor(title: "mockCardTitle",
                                                       issuedBy: "mockIssuer",
                                                       backgroundColor: "mockColor",
                                                       textColor: "mockTextColor",
                                                       logo: nil,
                                                       cardDescription: "mockCardDescription")
        
        let mockConsentDescriptor = ConsentDisplayDescriptor(title: nil,
                                                             instructions: "mockInstruction")
        
        let mockDisplayDescriptor = DisplayDescriptor(id: "mockDisplayDescriptor",
                                                      locale: nil,
                                                      contract: nil,
                                                      card: mockCardDescriptor,
                                                      consent: mockConsentDescriptor,
                                                      claims: [:])
        
        return mockDisplayDescriptor
        
    }
    
    private let testSignedContract = "eyJhbGciOiJFUzI1NksiLCJraWQiOiJkaWQ6d2ViOnRlc3R2Y3ZlcmlmaWVyLmF6dXJld2Vic2l0ZXMubmV0I2U2Y2Q4MjI1Y2UzYzRlMzY5M2MxMjM4MmYyYjdkNWU0dmNTaWduaW5nS2V5LWQ1N2QwIiwidHlwIjoiSldUIn0.eyJpZCI6IlZlcmlmaWVkIGVtcGxveWVlIiwiZGlzcGxheSI6eyJsb2NhbGUiOiJlbi1VUyIsImNvbnRyYWN0IjoiaHR0cHM6Ly9iZXRhLmRpZC5tc2lkZW50aXR5LmNvbS92MS4wLzljNTliZThiLWJkMTgtNDVkOS1iOWQ5LTA4MmJjMDdjMDk0Zi92ZXJpZmlhYmxlQ3JlZGVudGlhbC9jb250cmFjdHMvVmVyaWZpZWQlMjBlbXBsb3llZSIsImNhcmQiOnsidGl0bGUiOiJWZXJpZmllZCBFbXBsb3llZSIsImlzc3VlZEJ5IjoiQ29udG9zbyIsImJhY2tncm91bmRDb2xvciI6IiMyODJENkQiLCJ0ZXh0Q29sb3IiOiIjRkZGRkZGIiwibG9nbyI6eyJ1cmkiOiJodHRwczovL3Rlc3R2Y3ZlcmlmaWVyLmF6dXJld2Vic2l0ZXMubmV0L2ltYWdlcy9yZXRyb19sb2dvLnBuZyIsImRlc2NyaXB0aW9uIjoiRGVmYXVsdCB2ZXJpZmllZCBlbXBsb3llZSBsb2dvIn0sImRlc2NyaXB0aW9uIjoiVGhpcyB2ZXJpZmlhYmxlIGNyZWRlbnRpYWwgaXMgaXNzdWVkIHRvIGFsbCBtZW1iZXJzIG9mIHRoZSBDb250b3NvIG9yZy4ifSwiY29uc2VudCI6eyJ0aXRsZSI6IkRvIHlvdSB3YW50IHRvIGFjY2VwdCB0aGUgdmVyaWZpZWQgZW1wbG95ZWUgY3JlZGVudGlhbCBmcm9tIENvbnRvc28uIiwiaW5zdHJ1Y3Rpb25zIjoiUGxlYXNlIGxvZyBpbiB3aXRoIHlvdXIgQ29udG9zbyBhY2NvdW50IHRvIHJlY2VpdmUgdGhpcyBjcmVkZW50aWFsLiJ9LCJjbGFpbXMiOnsidmMuY3JlZGVudGlhbFN1YmplY3QuZ2l2ZW5OYW1lIjp7InR5cGUiOiJTdHJpbmciLCJsYWJlbCI6Ik5hbWUifSwidmMuY3JlZGVudGlhbFN1YmplY3Quc3VybmFtZSI6eyJ0eXBlIjoiU3RyaW5nIiwibGFiZWwiOiJTdXJuYW1lIn0sInZjLmNyZWRlbnRpYWxTdWJqZWN0Lm1haWwiOnsidHlwZSI6IlN0cmluZyIsImxhYmVsIjoiRW1haWwifSwidmMuY3JlZGVudGlhbFN1YmplY3Quam9iVGl0bGUiOnsidHlwZSI6IlN0cmluZyIsImxhYmVsIjoiSm9iIHRpdGxlIn0sInZjLmNyZWRlbnRpYWxTdWJqZWN0LnBob3RvIjp7InR5cGUiOiJpbWFnZS9qcGc7YmFzZTY0dXJsIiwibGFiZWwiOiJVc2VyIHBpY3R1cmUifSwidmMuY3JlZGVudGlhbFN1YmplY3QuZGlzcGxheU5hbWUiOnsidHlwZSI6IlN0cmluZyIsImxhYmVsIjoiRGlzcGxheSBuYW1lIn0sInZjLmNyZWRlbnRpYWxTdWJqZWN0LnByZWZlcnJlZExhbmd1YWdlIjp7InR5cGUiOiJTdHJpbmciLCJsYWJlbCI6IlByZWZlcnJlZCBsYW5ndWFnZSJ9LCJ2Yy5jcmVkZW50aWFsU3ViamVjdC5yZXZvY2F0aW9uSWQiOnsidHlwZSI6IlN0cmluZyIsImxhYmVsIjoiUmV2b2NhdGlvbiBpZCJ9fSwiaWQiOiJkaXNwbGF5In0sImlucHV0Ijp7ImNyZWRlbnRpYWxJc3N1ZXIiOiJodHRwczovL2JldGEuZGlkLm1zaWRlbnRpdHkuY29tL3YxLjAvOWM1OWJlOGItYmQxOC00NWQ5LWI5ZDktMDgyYmMwN2MwOTRmL3ZlcmlmaWFibGVDcmVkZW50aWFsL2NhcmQvaXNzdWUiLCJpc3N1ZXIiOiJkaWQ6d2ViOnRlc3R2Y3ZlcmlmaWVyLmF6dXJld2Vic2l0ZXMubmV0IiwiYXR0ZXN0YXRpb25zIjp7ImFjY2Vzc1Rva2VucyI6W3siaWQiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vOWM1OWJlOGItYmQxOC00NWQ5LWI5ZDktMDgyYmMwN2MwOTRmL3YyLjAiLCJlbmNyeXB0ZWQiOmZhbHNlLCJjbGFpbXMiOltdLCJyZXF1aXJlZCI6dHJ1ZSwiY29uZmlndXJhdGlvbiI6Imh0dHBzOi8vbG9naW4ubWljcm9zb2Z0b25saW5lLmNvbS85YzU5YmU4Yi1iZDE4LTQ1ZDktYjlkOS0wODJiYzA3YzA5NGYvdjIuMCIsInJlc291cmNlSWQiOiJiYjJhNjRlZS01ZDI5LTRiMDctYTQ5MS0yNTgwNmRjODU0ZDMiLCJvYm9TY29wZSI6IlVzZXIuUmVhZC5BbGwifV19LCJpZCI6ImlucHV0In0sImlzcyI6ImRpZDp3ZWI6dGVzdHZjdmVyaWZpZXIuYXp1cmV3ZWJzaXRlcy5uZXQiLCJpYXQiOjE2NzEyMTM0NTF9.nze68wVJ5FTRzypyO7Twfev8-UVpIyoqrDSjA6GKJOmcn2zqgLDSPMVolWTibIxga1Lq_W5SRx9Vt2S2vCOi8A"
}

