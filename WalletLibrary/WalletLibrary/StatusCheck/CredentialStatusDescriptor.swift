/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/**
 * The `credentialStatus` entry embedded in a Verifiable Credential JWT.
 *
 * Normalises the Entra / W3C variants — `StatusList2021Entry`, `RevocationList2021Status` (both use
 * `statusListIndex` / `statusListCredential`) and `RevocationList2020Status` (uses
 * `revocationListIndex` / `revocationListCredential`) — behind `effectiveStatusListCredential` and
 * `effectiveStatusListIndex`, so callers don't branch on `type`.
 */
struct CredentialStatusDescriptor: Equatable {

    let id: String
    let type: String
    let statusPurpose: String
    let statusListIndex: Int
    let statusListCredential: String
    let revocationListIndex: Int
    let revocationListCredential: String

    /// URL of the status list credential, normalised across the known type variants.
    var effectiveStatusListCredential: String {
        statusListCredential.isEmpty ? revocationListCredential : statusListCredential
    }

    /// Bit index within the status list bitstring, normalised across the known type variants.
    var effectiveStatusListIndex: Int {
        statusListCredential.isEmpty ? revocationListIndex : statusListIndex
    }

    /// Builds a descriptor from a parsed `credentialStatus` JSON object. Returns `nil` when the entry
    /// carries neither a status list reference nor an id, i.e. there is nothing to check.
    init?(json: [String: Any]) {
        self.id = json["id"] as? String ?? ""
        self.type = (json["type"] as? String) ?? (json["type"] as? [String])?.first ?? ""
        self.statusPurpose = json["statusPurpose"] as? String ?? ""
        self.statusListIndex = CredentialStatusDescriptor.intValue(json["statusListIndex"])
        self.statusListCredential = json["statusListCredential"] as? String ?? ""
        self.revocationListIndex = CredentialStatusDescriptor.intValue(json["revocationListIndex"])
        self.revocationListCredential = json["revocationListCredential"] as? String ?? ""

        if effectiveStatusListCredential.isEmpty && id.isEmpty {
            return nil
        }
    }

    /// Status list indices appear as either a JSON number or a numeric string across issuers.
    private static func intValue(_ value: Any?) -> Int {
        switch value {
        case let int as Int: return int
        case let number as NSNumber: return number.intValue
        case let string as String: return Int(string) ?? 0
        case let double as Double: return Int(double)
        default: return 0
        }
    }
}
