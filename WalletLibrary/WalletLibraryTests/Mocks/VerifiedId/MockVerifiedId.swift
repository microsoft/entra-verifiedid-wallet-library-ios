/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedId: VerifiedId, Equatable {
    
    var id: String
    
    var double: Double?
    
    var expiresOn: Date?
    
    var issuedOn: Date
    
    var style: VerifiedIdStyle
    
    enum CodingKeys: String, CodingKey {
        case id, issuedOn, expiresOn, double
        case style
    }
    
    init(id: String,
         double: Double? = nil,
         expiresOn: Date? = nil,
         issuedOn: Date,
         style: VerifiedIdStyle = MockVerifiedIdStyle()) {
        self.id = id
        self.double = double
        self.expiresOn = expiresOn
        self.issuedOn = issuedOn
        self.style = style
    }
    
    func getClaims() -> [VerifiedIdClaim] {
        return []
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(String.self, forKey: .id)
        let double = try values.decode(Double.self, forKey: .double)
        let style = try values.decode(MockVerifiedIdStyle.self, forKey: .style)
        self.init(id: id, double: double, issuedOn: Date(), style: style)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(double, forKey: .double)
        try container.encode(style as! MockVerifiedIdStyle, forKey: .style)
    }
    
    static func == (lhs: MockVerifiedId, rhs: MockVerifiedId) -> Bool {
        return lhs.id == rhs.id
    }
}
