/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdClientTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFlowExample() async throws {
        let builder = VerifiedIdClientBuilder()
        let client = builder.build()
        let input = URLInput(url: URL(string: "openid-vc://?request_uri=https://beta.did.msidentity.com/v1.0/tenants/9c59be8b-bd18-45d9-b9d9-082bc07c094f/verifiableCredentials/presentationRequests/49027fe8-05c6-4524-9b0c-0ff8c54c8b7d")!)

        let request = try await client.createVerifiedIdRequest(from: input)
        print(request.rootOfTrust)
        print(request.requirement)

    }
}
