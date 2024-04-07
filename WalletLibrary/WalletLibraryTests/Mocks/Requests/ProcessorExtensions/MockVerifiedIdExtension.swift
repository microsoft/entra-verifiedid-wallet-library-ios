/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedIdExtension: VerifiedIdExtendable
{
    var prefer: [String]
    
    var processors: [any RequestProcessorExtendable]
    
    init(prefer: [String], processors: [any RequestProcessorExtendable])
    {
        self.prefer = prefer
        self.processors = processors
    }
    
    func createRequestProcessorExtensions(configuration: ExtensionConfiguration) -> [any RequestProcessorExtendable]
    {
        return processors
    }
}
