/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines a factory for creating various token builders.
 * This factory pattern helps decouple the creation of token builders from their usage to help with testing.
 */
protocol TokenBuilderFactory
{
    /// Creates and returns an instance of a builder for Presentation Exchange ID Tokens.
    func createPresentationExchangeIdTokenBuilder() -> any PresentationExchangeIdTokenBuilding
    
    /// Creates and returns an instance of a builder for Verifiable Presentations.
    func createVerifiablePresentationBuilder(index: Int) -> any VerifiablePresentationBuilding
}

/**
 * A default implementation of `TokenBuilderFactory` that provides concrete instances of token builders.
 */
struct DefaultTokenBuilderFactory: TokenBuilderFactory
{
    /// Creates and returns an instance of a builder for Presentation Exchange ID Tokens.
    func createPresentationExchangeIdTokenBuilder() -> any PresentationExchangeIdTokenBuilding
    {
        return PresentationExchangeIdTokenBuilder()
    }
    
    /// Creates and returns an instance of a builder for Verifiable Presentations.
    func createVerifiablePresentationBuilder(index: Int) -> any VerifiablePresentationBuilding
    {
        return VerifiablePresentationBuilder(index: index)
    }
}
