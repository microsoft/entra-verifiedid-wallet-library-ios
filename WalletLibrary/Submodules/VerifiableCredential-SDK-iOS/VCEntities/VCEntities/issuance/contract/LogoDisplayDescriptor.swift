/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct LogoDisplayDescriptor: Codable, Equatable {
    
    let uri: String?
    let logoDescription: String?

    // Image can be already included in the logo display descriptor as a base64 encoded png
    let image: String?

    init(uri: String?, logoDescription: String?, image: String?) {
        self.uri = uri
        self.logoDescription = logoDescription
        self.image = image
    }
    
    enum CodingKeys: String, CodingKey {
        case uri
        case logoDescription = "description"
        case image
    }
}
