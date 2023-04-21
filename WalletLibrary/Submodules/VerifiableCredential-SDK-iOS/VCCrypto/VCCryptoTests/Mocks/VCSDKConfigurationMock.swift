/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


import Foundation
@testable import WalletLibrary

final class VCSDKConfigurationMock: VCSDKConfigurable {
    var accessGroupIdentifier: String?
    
    init(accessGroupIdentifier: String?) {
        self.accessGroupIdentifier = accessGroupIdentifier
    }
}
