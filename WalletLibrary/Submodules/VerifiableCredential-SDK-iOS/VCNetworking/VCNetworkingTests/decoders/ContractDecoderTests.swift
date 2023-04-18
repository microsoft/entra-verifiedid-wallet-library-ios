/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken

@testable import VCNetworking

class ContractDecoderTests: XCTestCase {
    
    var expectedContract: SignedContract!
    var encodedContractResponse: Data!
    let decoder = ContractDecoder()
    
    override func setUpWithError() throws {
        let encodedContractData = TestData.contract.rawValue.data(using: .utf8)!
        let contract = try JSONDecoder().decode(Contract.self, from: encodedContractData)
        expectedContract = SignedContract(headers: Header(), content: contract)
        let expectedContractResponse = ContractServiceResponse(token: try expectedContract.serialize())
        encodedContractResponse = try JSONEncoder().encode(expectedContractResponse)
    }
    
    func testDecode() throws {
        let actualContract = try decoder.decode(data: encodedContractResponse)
        XCTAssertEqual(actualContract.content, expectedContract.content)
    }
}
