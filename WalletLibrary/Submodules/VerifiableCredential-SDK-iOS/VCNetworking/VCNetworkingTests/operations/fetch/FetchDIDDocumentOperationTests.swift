/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class FetchDIDDocumentOperationTests: XCTestCase {
    private var fetchOperation: FetchDIDDocumentOperation!
    private let expectedIdentifier = "did:test:239235"
    private let expectedHttpResponse = "expectedHttpResponse324"
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [UrlProtocolMock.self]
        let urlSession = URLSession.init(configuration: configuration)
        do {
            fetchOperation = try FetchDIDDocumentOperation(withIdentifier: expectedIdentifier, session: urlSession)
        } catch {
            print(error)
        }
    }
    
    func testSuccessfulInit() {
        XCTAssertTrue(fetchOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(fetchOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(fetchOperation.retryHandler is NoRetry)
        XCTAssertEqual(fetchOperation.urlRequest.url!.absoluteString, VCSDKConfiguration.sharedInstance.discoveryUrl + "/" + expectedIdentifier)
    }

    func testValidDidWebPathSuccessfulInit() throws {
        let operation = try FetchDIDDocumentOperation(
            withIdentifier: "did:web:example.com:users:alice",
            session: fetchOperation.urlSession)

        XCTAssertEqual(
            operation.urlRequest.url!.absoluteString,
            VCSDKConfiguration.sharedInstance.discoveryUrl + "/did:web:example.com:users:alice")
    }

    func testUnsafeIdentifiersThrowMalformedInput() {
        let unsafeIdentifiers = [
            "not-a-did",
            "did:web:",
            "did:web:example.com::evil",
            "did:web:example.com:.:evil",
            "did:web:example.com:..:evil",
            "did:web:example.com:%2e%2e:evil",
            "did:web:example.com:%252e%252e:evil",
            "did:web:example.com:%252525252e%252525252e:evil",
            "did:web:example.com%2Fevil",
            "did:web:example.com%5Cevil",
            "did:web:example.com%3Fversion=1",
            "did:web:example.com%23key-1",
            "did:web:example.com/../evil",
            "did:web:example.com\\..\\evil",
            "did:web:example.com?version=1",
            "did:web:example.com#key-1",
            "DID:web:example.com",
            "did:Web:example.com"
        ]

        for identifier in unsafeIdentifiers {
            XCTAssertThrowsError(
                try FetchDIDDocumentOperation(
                    withIdentifier: identifier,
                    session: fetchOperation.urlSession),
                "Expected \(identifier) to be rejected.")
        }
    }

    func testMismatchedDocumentIdentifierThrowsMalformedInput() {
        let document = IdentifierDocument(
            service: nil,
            verificationMethod: nil,
            authentication: [],
            id: "did:test:attacker")

        XCTAssertThrowsError(
            try DIDDiscoveryValidation.validate(
                document: document,
                requestedIdentifier: expectedIdentifier))
    }
}
