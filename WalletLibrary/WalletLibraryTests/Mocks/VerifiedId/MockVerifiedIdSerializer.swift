/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedIdSerializer<SerializedFormat>: VerifiedIdSerializing
{
    enum ExpectedError: Error
    {
        case SerializerShouldThrow
        case ExpectedResultNotSet
    }
    
    typealias SerializedFormat = SerializedFormat
    
    private let doesThrow: Bool
    
    private let expectedResult: SerializedFormat?
    
    init(doesThrow: Bool = false,
         expectedResult: SerializedFormat? = nil)
    {
        self.doesThrow = doesThrow
        self.expectedResult = expectedResult
    }
    
    func serialize(verifiedId: VerifiedId) throws -> SerializedFormat
    {
        if doesThrow
        {
            throw ExpectedError.SerializerShouldThrow
        }
        
        if let expectedResult = expectedResult
        {
            return expectedResult
        }
        
        throw ExpectedError.ExpectedResultNotSet
    }
}
