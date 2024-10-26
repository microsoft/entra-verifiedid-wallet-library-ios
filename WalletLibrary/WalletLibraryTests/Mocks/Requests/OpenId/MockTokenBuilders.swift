/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockTokenBuilderFactory: TokenBuilderFactory
{
    private let vpTokenBuilderSpy: ((Int) -> ())?
    
    private let doesPEIdTokenBuilderThrow: Bool
    
    private let doesVPTokenBuilderThrow: Bool
    
    let expectedResultForPEIdToken: PresentationResponseToken
    
    let expectedResultForVPToken: VerifiablePresentation
    
    init(vpTokenBuilderSpy: ((Int) -> ())? = nil,
         doesPEIdTokenBuilderThrow: Bool = false,
         doesVPTokenBuilderThrow: Bool = false)
    {
        self.vpTokenBuilderSpy = vpTokenBuilderSpy
        self.doesPEIdTokenBuilderThrow = doesPEIdTokenBuilderThrow
        self.doesVPTokenBuilderThrow = doesVPTokenBuilderThrow
        self.expectedResultForPEIdToken = PresentationResponseToken(headers: Header(),
                                                                    content: PresentationResponseClaims())!
        self.expectedResultForVPToken = VerifiablePresentation(headers: Header(),
                                                               content: VerifiablePresentationClaims(verifiablePresentation: nil))!
    }
    
    func createPresentationExchangeIdTokenBuilder() -> PresentationExchangeIdTokenBuilding
    {
        return MockPEIdTokenBuilder(doesThrow: doesPEIdTokenBuilderThrow,
                                    expectedResult: expectedResultForPEIdToken)
    }
    
    func createVerifiablePresentationBuilder(index: Int) ->VerifiablePresentationBuilding
    {
        vpTokenBuilderSpy?(index)
        return MockVPBuilder(index: index,
                             doesThrow: doesVPTokenBuilderThrow,
                             expectedResult: expectedResultForVPToken)
    }
}

struct MockPEIdTokenBuilder: PresentationExchangeIdTokenBuilding
{
    enum ExpectedError: Error
    {
        case ExpectedToThrow
        case ExpectedResultNotSet
    }
    
    private let doesThrow: Bool
    
    private let expectedResult: PresentationResponseToken
    
    init(doesThrow: Bool = false,
         expectedResult: PresentationResponseToken)
    {
        self.doesThrow = doesThrow
        self.expectedResult = expectedResult
    }
    
    func build(inputDescriptors: [InputDescriptorMapping],
               definitionId: String,
               audience: String,
               nonce: String,
               identifier: HolderIdentifier) throws -> PresentationResponseToken
    {
        if doesThrow
        {
            throw ExpectedError.ExpectedToThrow
        }
        
        return expectedResult
    }
}

struct MockVPBuilder: VerifiablePresentationBuilding
{
    enum ExpectedError: Error
    {
        case ExpectedToThrow
    }
    
    private let doesThrow: Bool
    
    private let expectedResult: VerifiablePresentation
    
    private let wrappedBuilder: VerifiablePresentationBuilder
    
    init(index: Int,
         doesThrow: Bool = false,
         expectedResult: VerifiablePresentation)
    {
        self.wrappedBuilder = VerifiablePresentationBuilder(index: index)
        self.doesThrow = doesThrow
        self.expectedResult = expectedResult
    }
    
    func canInclude(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        wrappedBuilder.canInclude(partialInputDescriptor: partialInputDescriptor)
    }
    
    func add(partialInputDescriptor: PartialInputDescriptor)
    {
        wrappedBuilder.add(partialInputDescriptor: partialInputDescriptor)
    }
    
    func buildInputDescriptors() -> [InputDescriptorMapping]
    {
        wrappedBuilder.buildInputDescriptors()
    }
    
    func buildVerifiablePresentation(audience: String,
                                     nonce: String,
                                     identifier: HolderIdentifier) throws -> VerifiablePresentation
    {
        if doesThrow
        {
            throw ExpectedError.ExpectedToThrow
        }
        
        return expectedResult
    }
}
