/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import CoreData
import WalletLibrary

struct VerifiedIdRepository {
    
    let verifiedIdClient: VerifiedIdClient
    
    let store = PersistenceController.shared.container
    
    init(verifiedIdClient: VerifiedIdClient) {
        self.verifiedIdClient = verifiedIdClient
    }
    
    func save(verifiedId: VerifiedId) throws {
        let rawVerifiedId = try verifiedIdClient.encode(verifiedId: verifiedId).get()
        let viewContext = store.viewContext
        let newVerifiedId = RawVerifiedId(context: viewContext)
        newVerifiedId.raw = rawVerifiedId
        try viewContext.save()
    }
    
    func delete(verifiedId: VerifiedId) throws {
        let viewContext = store.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RawVerifiedId")
        let results = try viewContext.fetch(request)
        
        for result in results as! [NSManagedObject] {
            let id = result.value(forKey: "id") as! String
            if verifiedId.id == id {
                viewContext.delete(result)
            }
        }
    }
    
    func getAllStoredVerifiedIds() -> [VerifiedId] {
        let viewContext = store.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RawVerifiedId")
        
        var results: [NSManagedObject]
        do {
            results = (try viewContext.fetch(request)) as! [NSManagedObject]
        } catch {
            return []
        }

        var verifiedIds: [VerifiedId] = []
        for result in results {
            let rawValue = result.value(forKey: "raw") as! Data
            if let verifiedId = try? verifiedIdClient.decodeVerifiedId(from: rawValue).get() {
                verifiedIds.append(verifiedId)
            }
        }

        return verifiedIds
    }
}
