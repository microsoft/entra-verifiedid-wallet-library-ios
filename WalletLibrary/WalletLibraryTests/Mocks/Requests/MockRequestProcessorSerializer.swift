/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockRequestProcessorSerializer: RequestProcessorSerializing
{
    func serialize<T>(requirement: any WalletLibrary.Requirement,
                      verifiedIdSerializer: any WalletLibrary.VerifiedIdSerializing<T>) throws { }
}
