//
//  Copyright (C) Microsoft Corporation. All rights reserved.
//

/**
 * Additional information for continuation
 */
public struct ContinuationDescriptor: Codable, Equatable {
    /// Identifier the user would know
    public let upn: String?
    
    /// continuation url
    public let url: String?
    
    /// continuation payload
    public let payload: String?
    
    public init(upn: String?,
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
