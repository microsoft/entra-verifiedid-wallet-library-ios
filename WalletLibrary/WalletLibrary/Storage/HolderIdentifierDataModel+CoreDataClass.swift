/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CoreData

@objc(HolderIdentifierDataModel)
public class HolderIdentifierDataModel: NSManagedObject, HolderIdentifierStoredProperties
{
    convenience init(holderIdentifier: HolderIdentifierStoredProperties,
                     context: NSManagedObjectContext)
    {
        self.init(context: context)
        self.keyId = holderIdentifier.keyId
        self.id = holderIdentifier.id
        self.didMethod = holderIdentifier.didMethod
        self.algorithm = holderIdentifier.algorithm
        self.keyReference = holderIdentifier.keyReference
    }
}
