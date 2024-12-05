/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import CoreData


extension IdentifierModel
{
    func toIdentifierDataModel(identityDataModelContainer: NSPersistentContainer) -> IdentifierDataModel
    {
        
        let model = NSEntityDescription.insertNewObject(forEntityName:  CoreDataManager.Constants.identifierModel,
                                                        into: identityDataModelContainer.viewContext) as! IdentifierDataModel
        model.alias = self.alias
        model.did = self.did
        model.recoveryKeyAlias = self.recoveryKeyAlias
        model.recoveryKeyId = self.recoveryKeyId
        model.signingKeyAlias = self.signingKeyAlias
        model.signingKeyId = self.signingKeyId
        model.updateKeyAlias = self.updateKeyAlias
        model.updateKeyId = self.updateKeyId
        return model
    }
}
