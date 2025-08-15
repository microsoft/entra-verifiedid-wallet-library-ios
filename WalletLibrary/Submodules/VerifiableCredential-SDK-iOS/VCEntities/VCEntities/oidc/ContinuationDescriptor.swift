//
//  Copyright (C) Microsoft Corporation. All rights reserved.
//

/**
 * Additional information for continuation
 */
struct ContinuationDescriptor: Codable, Equatable {
    /// Identifier the user would know
    let upn: String?
    
    /// continuation url
    let url: String?
    
    /// continuation payload
    let payload: String?
    
    init(upn: String?,
         clientPurpose: String?,
         url: String?,
         payload: String?) {
        self.upn = upn
        self.url = url
        self.payload = payload
    }

    enum CodingKeys: String, CodingKey {
        case upn, url, payload
    }
}
