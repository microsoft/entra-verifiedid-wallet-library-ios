/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import CoreData
import WalletLibrary

struct VerifiedIdRepository {
    
    /// TODO: add persistent storage.
    var storedVerifiedIds: [VerifiedId] = []
    
    mutating func save(verifiedId: VerifiedId) throws {
        storedVerifiedIds.append(verifiedId)
    }
    
    mutating func delete(verifiedId: VerifiedId) throws {
        storedVerifiedIds.removeAll {
            $0.id == verifiedId.id
        }
    }
    
    func getAllStoredVerifiedIds() throws -> [VerifiedId] {
        return storedVerifiedIds
    }
}
