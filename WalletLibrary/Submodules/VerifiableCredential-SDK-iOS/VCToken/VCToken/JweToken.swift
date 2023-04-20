/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public struct JweToken {
    public let headers: Header
    public let aad: Data
    public let encryptedKey: Data
    public let iv: Data
    public let ciperText: Data
    public let authenticationTag: Data
}
