/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utilities such as the `Logger` and `ExtensionIdentityManager` that are configured in builder and
 * all of the library will use.
 */
public class ExtensionConfiguration
{
    /**
     * Logs and metrics class.
     */
    public let logger: WalletLibraryLogger
    
    /**
     * Identifier Manager for extension use.
     */
    public let identifierManager: ExtensionIdentifierManager
    
    init(identifierManager: IdentifierManager,
         libraryConfiguration: LibraryConfiguration)
    {
        self.logger = libraryConfiguration.logger
        self.identifierManager = InternalExtensionIdentifierManager(identifierManager: identifierManager,
                                                                    libraryConfiguration: libraryConfiguration)
    }
}
