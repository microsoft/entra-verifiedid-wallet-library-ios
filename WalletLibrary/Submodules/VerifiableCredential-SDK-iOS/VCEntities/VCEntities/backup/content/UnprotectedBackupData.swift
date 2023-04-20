/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/// A ProtectedBackup holds a UnprotectedBackupData in some shape or form. The details are defined by implementations of this protocol. e.g. a JWE Token encrypted by a password.
public struct UnprotectedBackupData {
    
    public let type: String
    public let encoded: Data

    public init(type: String, encoded: Data) {
        self.type = type
        self.encoded = encoded
    }
}
