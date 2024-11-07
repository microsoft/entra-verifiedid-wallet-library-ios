/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CoreData

@objc(HolderIdentifierDataModel)
public class HolderIdentifierDataModel: NSManagedObject 
{
    convenience init(keyId: UUID,
                     holderIdentifier: HolderIdentifier,
                     context: NSManagedObjectContext)
    {
        self.init(context: context)
        self.keyId = keyId
        self.didMethod = holderIdentifier.method
        self.algorithm = holderIdentifier.algorithm
        self.keyReference = holderIdentifier.keyReference
    }

}
