/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Describes the credentail type of the vc requested.
struct InputDescriptorSchema: Codable, Equatable {

    /// List of uris that describe the credential requested.
    let uri: String?
    
    init(uri: String?) {
        self.uri = uri
    }
    
    enum CodingKeys: String, CodingKey {
        case uri
    }
}
