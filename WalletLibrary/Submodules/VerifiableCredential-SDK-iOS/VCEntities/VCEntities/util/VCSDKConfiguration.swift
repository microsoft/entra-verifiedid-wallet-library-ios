/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif

struct VCSDKConfiguration: VCSDKConfigurable {
    
    static var sharedInstance = VCSDKConfiguration()
    
    private(set) var accessGroupIdentifier: String?
    
    private(set) var discoveryUrl: String = "https://dev.discover.did.msidentity.com/private/identifiers"
    
    private init() {}
    
    mutating func setAccessGroupIdentifier(with id: String) {
        self.accessGroupIdentifier = id
    }
    
    mutating func setDiscoveryUrl(with url: String) {
        self.discoveryUrl = url
    }
}
