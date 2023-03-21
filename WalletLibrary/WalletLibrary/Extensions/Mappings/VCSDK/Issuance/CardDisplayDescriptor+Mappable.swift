/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.CardDisplayDescriptor class.
 */
extension CardDisplayDescriptor: Mappable {
    func map(using mapper: Mapping) throws -> Manifest2022VerifiedIdStyle {
        
        var logoUrl: URL? = nil
        if let url = logo?.uri {
            logoUrl = URL(string: url)
        }
        
        return Manifest2022VerifiedIdStyle(name: title,
                                           issuer: issuedBy,
                                           backgroundColor: backgroundColor,
                                           textColor: textColor,
                                           description: cardDescription,
                                           logoUrl: logoUrl,
                                           logoAltText: logo?.logoDescription)
    }
}
