/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCCrypto

public struct MockVCSDKConfiguration: VCSDKConfigurable {
    
    public private(set) var accessGroupIdentifier: String?
    
    init() {}
    
    mutating func setAccessGroupIdentifier(with id: String) {
        self.accessGroupIdentifier = id
    }
}
