/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockOpenIdRawRequest: OpenIdRawRequest, Equatable {
    
    var raw: Data?
    
    init(raw: Data?) {
        self.raw = raw
    }
}
