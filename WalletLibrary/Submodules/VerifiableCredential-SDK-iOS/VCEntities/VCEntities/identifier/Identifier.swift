/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct Identifier {
    let longFormDid: String
    let didDocumentKeys: [KeyContainer]
    let updateKey: KeyContainer
    let recoveryKey: KeyContainer
    let alias: String

    var did: String
    {
        get {
            return longFormDid
        }
    }

    init(longFormDid: String,
                didDocumentKeys: [KeyContainer],
                updateKey: KeyContainer,
                recoveryKey: KeyContainer,
                alias: String) {
        self.longFormDid = longFormDid
        self.didDocumentKeys = didDocumentKeys
        self.updateKey = updateKey
        self.recoveryKey = recoveryKey
        self.alias = alias
    }
}
