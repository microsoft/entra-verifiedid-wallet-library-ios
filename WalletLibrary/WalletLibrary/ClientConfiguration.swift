/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class ClientConfiguration: VerifiedIdClientConfiguration {
    let logConsumer: WalletLibraryLogConsumer?
    
    let protocolConfigurations: [ProtocolConfiguration]
    
    init(logConsumer: WalletLibraryLogConsumer?, protocolConfigurations: [ProtocolConfiguration]) {
        self.logConsumer = logConsumer
        self.protocolConfigurations = protocolConfigurations
    }
}
