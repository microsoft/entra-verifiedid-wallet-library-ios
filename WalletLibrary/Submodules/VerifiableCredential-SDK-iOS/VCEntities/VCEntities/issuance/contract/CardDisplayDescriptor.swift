/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct CardDisplayDescriptor: Codable, Equatable {
    
    let title: String
    let issuedBy: String
    let backgroundColor: String
    let textColor: String
    let logo: LogoDisplayDescriptor?
    let cardDescription: String

    enum CodingKeys: String, CodingKey {
        case title, issuedBy, backgroundColor, textColor, logo
        case cardDescription = "description"
    }

    init(title: String, issuedBy: String, backgroundColor: String, textColor: String, logo: LogoDisplayDescriptor?, cardDescription: String) {
        self.title = title
        self.issuedBy = issuedBy
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.logo = logo
        self.cardDescription = cardDescription
    }
}
