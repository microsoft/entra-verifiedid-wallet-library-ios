/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class LibraryConfiguration {
    
    let logger: WalletLibraryLogger
    
    let mapper: Mapping
    
    init(logger: WalletLibraryLogger, mapper: Mapping) {
        self.logger = logger
        self.mapper = mapper
    }
}
