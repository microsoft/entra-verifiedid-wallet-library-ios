/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import CoreData
import WalletLibrary

struct VerifiedIdRepository {
    
    let container = PersistenceController.shared.container
    
    func save(verifiedId: VerifiedId) throws {
        let rawVerifiedId = try VerifiedIdEncoder().encode(verifiedId: verifiedId)
        let viewContext = container.viewContext
        let newVerifiedId = RawVerifiedId(context: viewContext)
        newVerifiedId.raw = rawVerifiedId
        try viewContext.save()
    }
    
    func delete(verifiedId: VerifiedId) throws {
        let viewContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RawVerifiedId")
        let results = try viewContext.fetch(request)
        
        for result in results as! [NSManagedObject] {
            let id = result.value(forKey: "id") as! String
            if verifiedId.id == id {
                viewContext.delete(result)
            }
        }
        
        try viewContext.save()
    }
    
    func getAllStoredVerifiedIds() throws -> [VerifiedId] {
        let viewContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RawVerifiedId")
        let results = try viewContext.fetch(request)
        
        var verifiedIds: [VerifiedId] = []
        for result in results as! [NSManagedObject] {
            let rawValue = result.value(forKey: "raw") as! Data
            let verifiedId = try VerifiedIdDecoder().decode(from: rawValue)
            verifiedIds.append(verifiedId)
        }
        
        return verifiedIds
    }
}
