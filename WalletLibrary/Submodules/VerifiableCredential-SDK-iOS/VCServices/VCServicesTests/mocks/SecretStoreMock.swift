/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation
@testable import VCCrypto
internal class SecretStoreMock: SecretStoring {

    private var memoryStore = [UUID: Data]()
    
    func getSecret(id: UUID, itemTypeCode: String, accessGroup: String?) throws -> Data {
        print("gettingSecret... " + id.uuidString)
        return memoryStore[id]!
    }
    
    func saveSecret(id: UUID, itemTypeCode: String, accessGroup: String?, value: inout Data) throws {
        print("savingSecret... " + id.uuidString)
        memoryStore[id] = value
    }
    
    func deleteSecret(id: UUID, itemTypeCode: String, accessGroup: String?) throws {
        print("deletingSecret... " + id.uuidString)
        memoryStore.removeValue(forKey: id)
    }
    
}
