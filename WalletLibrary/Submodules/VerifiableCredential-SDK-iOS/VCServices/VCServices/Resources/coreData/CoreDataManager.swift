/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation
import CoreData

enum CoreDataManagerError: Error {
    case unableToCreatePersistentContainer
    case persistentStoreNotLoaded
}

class CoreDataManager: HolderIdentifierStorage
{
    private struct Constants {
        static let bundleId = "com.microsoft.VCUseCase"
        static let model = "VerifiedIdDataModel"
        static let identifierModel = "IdentifierDataModel"
        static let extensionType = "momd"
        static let sqliteDescription = "sqlite"
    }
    
    static let sharedInstance = CoreDataManager()
    
    private var persistentContainer: NSPersistentContainer?
    
    let sdkLog: VCSDKLog
    
    private init(sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        
        self.sdkLog = sdkLog
        
        loadPersistentContainer(sdkLog: sdkLog)
    }
    
    /// Stores a `HolderIdentifierStoredProperties` object in the persistent storage.
    /// - Parameters:
    ///   - holder: The `HolderIdentifier` object to be stored.
    ///   - keyId: A `UUID` that uniquely identifies the holder in persistent storage.
    /// - Throws: A `CoreDataManagerError.persistentStoreNotLoaded` error if the persistent store is not loaded.
    func storeHolderIdentifier(holderIdentifier: HolderIdentifierStoredProperties) throws
    {
        guard let persistentContainerContext = persistentContainer?.viewContext else
        {
            throw CoreDataManagerError.persistentStoreNotLoaded
        }
        
        let storedIdentifier = HolderIdentifierDataModel(holderIdentifier: holderIdentifier,
                                                         context: persistentContainerContext)
        
        try persistentContainerContext.obtainPermanentIDs(for: [storedIdentifier])
        try persistentContainerContext.save()
    }
    
    /// Fetches all stored holder identifiers from the persistent storage.
    /// - Returns: An array of `HolderIdentifierStoredProperties` objects, representing the stored holder identifiers.
    /// - Throws: A `CoreDataManagerError.persistentStoreNotLoaded` error if the persistent store is not loaded.
    func fetchStoredHolderIdentifiers() throws -> [HolderIdentifierStoredProperties]
    {
        guard let persistentContainerContext = persistentContainer?.viewContext else
        {
            throw CoreDataManagerError.persistentStoreNotLoaded
        }
        
        let fetchRequest: NSFetchRequest<HolderIdentifierDataModel> = HolderIdentifierDataModel.fetchRequest()
        return try persistentContainerContext.fetch(fetchRequest)
    }
    
    func saveIdentifier(longformDid: String,
                        signingKeyId: UUID,
                        recoveryKeyId: UUID,
                        updateKeyId: UUID,
                        alias: String,
                        signingKeyAlias: String? = nil,
                        recoveryKeyAlias: String? = nil,
                        updateKeyAlias: String? = nil) throws {
        guard let persistentContainer = persistentContainer else {
            throw CoreDataManagerError.persistentStoreNotLoaded
        }
        
        let model = NSEntityDescription.insertNewObject(forEntityName: Constants.identifierModel,
                                                        into: persistentContainer.viewContext) as! IdentifierDataModel
        
        model.did = longformDid
        model.recoveryKeyId = recoveryKeyId
        model.signingKeyId = signingKeyId
        model.updateKeyId = updateKeyId
        model.alias = alias
        model.signingKeyAlias = signingKeyAlias
        model.recoveryKeyAlias = recoveryKeyAlias
        model.updateKeyAlias = updateKeyAlias
        
        try persistentContainer.viewContext.save()
    }
    
    func fetchIdentifiers() throws -> [IdentifierDataModel] {
        guard let persistentContainer = persistentContainer else {
            throw CoreDataManagerError.persistentStoreNotLoaded
        }
        
        let fetchRequest: NSFetchRequest<IdentifierDataModel> = IdentifierDataModel.fetchRequest()
        return try persistentContainer.viewContext.fetch(fetchRequest)
    }
    
    func deleteAllIdentifiers() throws {
        guard let persistentContainer = persistentContainer else {
            throw CoreDataManagerError.persistentStoreNotLoaded
        }
        
        let fetchRequest: NSFetchRequest<IdentifierDataModel> = IdentifierDataModel.fetchRequest()
        let models = try persistentContainer.viewContext.fetch(fetchRequest)
        
        for model in models {
            persistentContainer.viewContext.delete(model)
        }
        
        try persistentContainer.viewContext.save()
    }
    
    func deleteIdentifer(_ model:IdentifierDataModel) {
        persistentContainer?.viewContext.delete(model)
    }
    
    private func loadPersistentContainer(sdkLog: VCSDKLog) {
        
        let messageKitBundle = Bundle(for: Self.self)
        
        guard let modelURL = messageKitBundle.url(forResource: Constants.model, withExtension: Constants.extensionType),
              let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL) else {
            return
        }
        
        let container = NSPersistentContainer(name: Constants.model, managedObjectModel: managedObjectModel)
        
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions.append(description)
        container.viewContext.mergePolicy = NSMergePolicy.overwrite
        
        container.loadPersistentStores {
            [weak self] (storeDescription, error) in
            
            if let err = error?.localizedDescription {
                sdkLog.logError(message: err)
                return
            }

            self?.persistentContainer = container
        }
    }
}
