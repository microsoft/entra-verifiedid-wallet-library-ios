/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class MatchSubjectCryptoRequirement : CryptoRequirement {
    let subject: String
    init (subject: String) {
        self.subject = subject
    }
    
    func isSupported(identifier: any HolderIdentifier) -> Bool {
        identifier.id == subject
    }
}
