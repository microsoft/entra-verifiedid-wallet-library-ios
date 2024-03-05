/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utilities such as logger, identityManager that are configured in builder and
 * all of library will use.
 */
public class ExtensionConfiguration
{
    /**
     * Logs and metrics class
     */
    public let logger: WalletLibraryLogger
    
    /**
     * Identifier manager for extension use
     */
    public let identifierManager: ExtensionIdentifierManager
    
    init(logger: WalletLibraryLogger, identifierManager: IdentifierManager) {
        self.logger = logger
        self.identifierManager = ExtensionIdentifierManager(identifierManager: identifierManager)
    }
}
