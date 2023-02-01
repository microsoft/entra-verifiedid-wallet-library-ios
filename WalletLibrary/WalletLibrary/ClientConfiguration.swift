/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class ClientConfiguration: VerifiedIdClientConfiguration {
    let logConsumer: WalletLibraryLogConsumer?
    
    let requestProtocolMappings: [RequestProtocolMapping]
    
    init(logConsumer: WalletLibraryLogConsumer?, requestProtocolMappings: [RequestProtocolMapping]) {
        self.logConsumer = logConsumer
        self.requestProtocolMappings = requestProtocolMappings
    }
}
