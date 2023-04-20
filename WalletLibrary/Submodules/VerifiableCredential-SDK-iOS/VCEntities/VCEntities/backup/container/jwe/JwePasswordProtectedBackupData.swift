/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct JwePasswordProtectedBackupData : ProtectedBackupData {
    let content: String

    public func serialize() -> String {
        content
    }
}
