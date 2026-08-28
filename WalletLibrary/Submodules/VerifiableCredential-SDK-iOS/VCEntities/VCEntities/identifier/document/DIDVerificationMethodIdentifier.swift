/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct DIDVerificationMethodIdentifier {
    let did: String
    let relativeId: String

    var absoluteId: String {
        did + relativeId
    }

    init?(keyId: String) {
        let components = keyId.split(
            separator: "#",
            maxSplits: 1,
            omittingEmptySubsequences: false)
        guard components.count == 2,
              !components[0].isEmpty,
              !components[1].isEmpty,
              !components[1].contains("#") else {
            return nil
        }

        self.did = String(components[0])
        self.relativeId = "#\(components[1])"
    }
}
