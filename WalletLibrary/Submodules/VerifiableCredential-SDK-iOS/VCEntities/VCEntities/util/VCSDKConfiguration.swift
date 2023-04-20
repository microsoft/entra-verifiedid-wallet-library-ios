/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif

public struct VCSDKConfiguration: VCSDKConfigurable {
    
    public static var sharedInstance = VCSDKConfiguration()
    
    public private(set) var accessGroupIdentifier: String?
    
    public private(set) var discoveryUrl: String = "https://discover.did.msidentity.com/v1.0/identifiers"
    
    private init() {}
    
    public mutating func setAccessGroupIdentifier(with id: String) {
        self.accessGroupIdentifier = id
    }
    
    public mutating func setDiscoveryUrl(with url: String) {
        self.discoveryUrl = url
    }
}
