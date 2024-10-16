/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.CardDisplayDescriptor class.
 */
extension CardDisplayDescriptor: Mappable {
    func map(using mapper: Mapping) throws -> any VerifiedIdStyle {
        
        var logo: VerifiedIdLogo? = nil
        if let logoUri = self.logo?.uri,
           let url = URL(string: logoUri) {
            logo = VerifiedIdLogo(url: url, altText: self.logo?.logoDescription)
        }
        
        return BasicVerifiedIdStyle(name: title,
                                    issuer: issuedBy,
                                    backgroundColor: backgroundColor,
                                    textColor: textColor,
                                    description: cardDescription,
                                    logo: logo)
    }
}
