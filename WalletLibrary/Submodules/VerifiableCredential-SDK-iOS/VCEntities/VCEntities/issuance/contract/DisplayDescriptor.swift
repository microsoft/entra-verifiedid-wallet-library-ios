/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

public struct DisplayDescriptor: Codable, Equatable {
    
    public let id: String?
    public let locale: String?
    public let contract: String?
    public let card: CardDisplayDescriptor
    public let consent: ConsentDisplayDescriptor
    public let claims: [String: ClaimDisplayDescriptor]

    public init(id: String?, locale: String?, contract: String?, card: CardDisplayDescriptor, consent: ConsentDisplayDescriptor, claims: [String : ClaimDisplayDescriptor]) {
        self.id = id
        self.locale = locale
        self.contract = contract
        self.card = card
        self.consent = consent
        self.claims = claims
    }
}
