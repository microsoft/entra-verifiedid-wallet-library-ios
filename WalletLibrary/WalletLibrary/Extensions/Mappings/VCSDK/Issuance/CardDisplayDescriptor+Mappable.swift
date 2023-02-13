/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import UIKit

/**
 * An extension of the VCEntities.Contract class
 * to map Contract to VerifiedIdRequestContent.
 */
extension VCEntities.CardDisplayDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> MSVerifiedIdStyle {
        /// TODO implement
        let backgroundColor = UIColor(hex: self.backgroundColor)
        let textColor = UIColor(hex: self.textColor)
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}

public protocol VerifiedIdStyle {
    
}

public struct MSVerifiedIdStyle {
    let backgroundColor: UIColor
    
    let textColor: UIColor
}
