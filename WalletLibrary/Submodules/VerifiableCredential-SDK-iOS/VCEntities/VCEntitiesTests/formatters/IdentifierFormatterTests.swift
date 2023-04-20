/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCToken

@testable import VCEntities

class IdentifierFormatterTests: XCTestCase {
    
    let formatter = IdentifierFormatter()
    let expectedDid = "did:ion:EiBqI3vUhJSlAfpBMqf9K0xTL-qwvsqv3nUSLxB5npih9g:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W3siaWQiOiJ0ZXN0S2V5IiwicHVibGljS2V5SndrIjp7ImFsZyI6IkVTMjU2SyIsImNydiI6InNlY3AyNTZrMSIsImtleV9vcHMiOlsidmVyaWZ5Il0sImtpZCI6InRlc3RLZXkiLCJrdHkiOiJFQyIsInVzZSI6InNpZyIsIngiOiJJcjVscVQyeURDWGRXSThIZ01qMmVyejlIVkNoRkZ2NEJkNzBvRHFjbHZzIiwieSI6Il91U1FiMk5OTzNNTW5zUzgzQnlNeGF5R2JrM09EWXhBbE14LV9ZT3c1b2MifSwicHVycG9zZXMiOlsiYXV0aGVudGljYXRpb24iXSwidHlwZSI6IkVjZHNhU2VjcDI1NmsxVmVyaWZpY2F0aW9uS2V5MjAxOSJ9XSwic2VydmljZXMiOltdfX1dLCJ1cGRhdGVDb21taXRtZW50IjoiRWlBSDMtLTg0cng5VjFLaUNtUWJOT2F2a0NxRS1aVy16ZEJjYkNBZzVjYklCZyJ9LCJzdWZmaXhEYXRhIjp7ImRlbHRhSGFzaCI6IkVpRDQ4N25LaFlvaFY5c004MEYxMEgwSmJHOXhyaTJKcDJPRk1aRmFKREhXWXciLCJyZWNvdmVyeUNvbW1pdG1lbnQiOiJFaUFIMy0tODRyeDlWMUtpQ21RYk5PYXZrQ3FFLVpXLXpkQmNiQ0FnNWNiSUJnIn19"
    
    func testFormatting() throws {
        let key = ECPublicJwk(x: "Ir5lqT2yDCXdWI8HgMj2erz9HVChFFv4Bd70oDqclvs", y: "_uSQb2NNO3MMnsS83ByMxayGbk3ODYxAlMx-_YOw5oc", keyId: "testKey")
        let actualDid = try formatter.createIonLongFormDid(recoveryKey: key, updateKey: key, didDocumentKeys: [key], serviceEndpoints: [])
        print(actualDid)
        XCTAssertEqual(actualDid, expectedDid)
        
    }
}
