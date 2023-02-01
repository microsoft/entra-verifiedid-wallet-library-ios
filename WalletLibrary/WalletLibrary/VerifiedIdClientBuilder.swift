/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder {
    
    var logger: WalletLibraryLogger?

    public init() {
        logger = WalletLibraryLogger()
    }

    /// Build the VerifiedIdClient with the set configuration from the builder.
    public func build() -> VerifiedIdClient {
        return VerifiedIdClient(builder: self)
    }

    /// Optional method to add a custom log consumer to VerifiedIdClient.
    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder {
        logger?.add(consumer: logConsumer)
        return self
    }
}
