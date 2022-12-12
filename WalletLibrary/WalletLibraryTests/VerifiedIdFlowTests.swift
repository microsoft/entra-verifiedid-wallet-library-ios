/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdFlowTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitiateFlow() async throws {
        let requestUri = URL(string: "openid-vc://?request_uri=https://beta.did.msidentity.com/v1.0/tenants/9c59be8b-bd18-45d9-b9d9-082bc07c094f/verifiableCredentials/issuanceRequests/4eba26a1-ce31-435b-9f2a-f8a783fce5f8")!
        let request = try await VerifiedIdFlow().initiate(requestUri: requestUri)
        print(request)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
