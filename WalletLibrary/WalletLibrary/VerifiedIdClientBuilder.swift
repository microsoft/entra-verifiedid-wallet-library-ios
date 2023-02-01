/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public class VerifiedIdClientBuilder {
    
    var logConsumer: WalletLibraryLogConsumer?
    
    lazy var protocolConfigurations: [ProtocolConfiguration] = {
        return registerProtocolConfigurations()
    }()

    public init() {
        logConsumer = nil
    }

    public func build() -> VerifiedIdClient {
        return VerifiedIdClient(builder: self)
    }

    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder {
        self.logConsumer = logConsumer
        return self
    }
    
    func with(protocolConfiguration: ProtocolConfiguration) -> VerifiedIdClientBuilder {
        self.protocolConfigurations.append(protocolConfiguration)
        return self
    }
    
    private func registerProtocolConfigurations() -> [ProtocolConfiguration] {
        let siopConfig = ProtocolConfiguration(protocolHandler: SIOPProtocolHandler(),
                                               supportedInputType: URLInput.self)
        return [siopConfig]
    }
}
