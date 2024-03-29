/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockRequestProcessorExtension<Processor: RequestProcessing>: RequestProcessorExtendable
{
    typealias RequestProcessor = Processor
    
    var wasParseCalled: Bool
    
    init()
    {
        wasParseCalled = false
    }
    
    func parse(rawRequest: Processor.RawRequestType, request: VerifiedIdPartialRequest) -> VerifiedIdPartialRequest
    {
        wasParseCalled = true
        return request
    }
}
