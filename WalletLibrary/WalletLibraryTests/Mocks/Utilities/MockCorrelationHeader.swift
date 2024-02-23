/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockCorrelationHeader: VerifiedIdCorrelationHeader {

    var name: String
    
    var value: String
    
    var wasUpdateCalled: Bool
    
    var wasResetCalled: Bool
    
    init(name: String = "mockName",
         value: String = "mockValue",
         wasUpdateCalled: Bool = false,
         wasResetCalled: Bool = false) {
        self.name = name
        self.value = value
        self.wasUpdateCalled = wasUpdateCalled
        self.wasResetCalled = wasResetCalled
    }
    
    func update() {
        wasUpdateCalled = true
    }
    
    func reset() {
        wasResetCalled = true
    }
}
