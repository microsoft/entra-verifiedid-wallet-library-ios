/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol HolderIdentifierBuilder
{
    func buildHolderIdentifier(didMethod: String,
                               keyId: UUID?,
                               keyReference: String,
                               algorithm: String) throws -> HolderIdentifier
}
