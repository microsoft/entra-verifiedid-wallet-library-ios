/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder {
    
    var logConsumer: WalletLibraryLogConsumer?
    
    lazy var requestProtocolMappings: [RequestProtocolMapping] = {
        return registerRequestProtocolMappings()
    }()

    public init() {
        logConsumer = nil
    }

    /// Build the VerifiedIdClient with the set configuration from the builder.
    public func build() -> VerifiedIdClient {
        return VerifiedIdClient(builder: self)
    }

    /// Optional method to add a custom log consumer to VerifiedIdClient.
    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder {
        self.logConsumer = logConsumer
        return self
    }
    
    private func registerRequestProtocolMappings() -> [RequestProtocolMapping] {
        return [SIOPURLProtocolMapping()]
    }
}
