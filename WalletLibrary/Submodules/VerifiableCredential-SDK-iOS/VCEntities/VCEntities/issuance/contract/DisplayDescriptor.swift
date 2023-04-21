/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

struct DisplayDescriptor: Codable, Equatable {
    
    let id: String?
    let locale: String?
    let contract: String?
    let card: CardDisplayDescriptor
    let consent: ConsentDisplayDescriptor
    let claims: [String: ClaimDisplayDescriptor]

    init(id: String?, locale: String?, contract: String?, card: CardDisplayDescriptor, consent: ConsentDisplayDescriptor, claims: [String : ClaimDisplayDescriptor]) {
        self.id = id
        self.locale = locale
        self.contract = contract
        self.card = card
        self.consent = consent
        self.claims = claims
    }
}
