/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public enum Microsoft2020BackupError : Error {
    case undecodableCredential(source:String)
}

open class Microsoft2020UnprotectedBackup : UnprotectedBackup {

    private struct Constants {
        static let OnTheWireBackupType = "MicrosoftWallet2020"
    }

    public var type = Constants.OnTheWireBackupType
    public var identifiers = Microsoft2020IdentifierBackup()
    public var vcs = [String:String]()
    public var vcsMetaInf = [String:VcMetadata]()

    public var metaInf: WalletMetadata?

    public init(metaInf: WalletMetadata? = nil) {
        self.metaInf = metaInf
    }
    
    public func add(credential: VerifiableCredential, metadata:VcMetadata) {
        
        if let id = credential.content.jti {
            self.vcs[id] = credential.rawValue
            self.vcsMetaInf[id] = metadata
        }
    }

    public func forEachCredential(completionHandler: @escaping (VerifiableCredential, VcMetadata?) throws -> Void) rethrows {
        
        try self.vcs.forEach { (key, value) in
            guard let credential = VerifiableCredential(from: value) else {
                // This might be better done during the parsing of the backup from JSON..?
                throw Microsoft2020BackupError.undecodableCredential(source: value)
            }
            
            let metadata = self.vcsMetaInf[key]
            try completionHandler(credential, metadata)
        }
    }
}
