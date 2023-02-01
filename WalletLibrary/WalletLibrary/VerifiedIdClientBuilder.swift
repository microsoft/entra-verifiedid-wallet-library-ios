/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public class VerifiedIdClientBuilder {
    
    var logConsumer: WalletLibraryLogConsumer?
    
    var protocolConfigurations: [ProtocolConfiguration] = []

    public init()
    {
        logConsumer = nil
    }

    public func build() -> VerifiedIdClient
    {
        return VerifiedIdClient(builder: self)
    }

    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder
    {
        self.logConsumer = logConsumer
        return self
    }
}

protocol VerifiedIdClientConfiguration {
    var logConsumer: WalletLibraryLogConsumer? { get }
    
    var protocolConfigurations: [ProtocolConfiguration] { get }
}

class ClientConfiguration: VerifiedIdClientConfiguration {
    let logConsumer: WalletLibraryLogConsumer?
    
    let protocolConfigurations: [ProtocolConfiguration]
    
    init(logConsumer: WalletLibraryLogConsumer?, protocolConfigurations: [ProtocolConfiguration]) {
        self.logConsumer = logConsumer
        self.protocolConfigurations = protocolConfigurations
    }
}
