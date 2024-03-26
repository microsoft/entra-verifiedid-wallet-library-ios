/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol TokenBuilderFactory
{
    func createPEIdTokenBuilder() -> any PresentationExchangeIdTokenBuilding
    
    func createVPTokenBuilder(index: Int) -> any VerifiablePresentationBuilding
}

struct PETokenBuilderFactory: TokenBuilderFactory
{
    func createPEIdTokenBuilder() -> any PresentationExchangeIdTokenBuilding
    {
        return PresentationExchangeIdTokenBuilder()
    }
    
    func createVPTokenBuilder(index: Int) -> any VerifiablePresentationBuilding
    {
        return VerifiablePresentationBuilder(index: index)
    }
}
