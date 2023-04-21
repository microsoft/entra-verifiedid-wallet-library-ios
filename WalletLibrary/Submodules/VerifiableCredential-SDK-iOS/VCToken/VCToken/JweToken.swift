/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct JweToken {
    let headers: Header
    let aad: Data
    let encryptedKey: Data
    let iv: Data
    let ciperText: Data
    let authenticationTag: Data
}
