/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockPresentationExchangeRequirement: PresentationExchangeRequirement, Requirement
{
    var required: Bool = true
    
    var inputDescriptorId: String
    
    var format: String = "jwt_vc"
    
    var exclusivePresentationWith: [String]?
    
    init(inputDescriptorId: String, exclusivePresentationWith: [String]? = nil)
    {
        self.inputDescriptorId = inputDescriptorId
        self.exclusivePresentationWith = exclusivePresentationWith
    }
    
    func validate() -> WalletLibrary.VerifiedIdResult<Void> 
    {
        return VerifiedIdResult.success(())
    }
    
    func serialize<T>(protocolSerializer: RequestProcessorSerializing,
                      verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T? 
    {
        return try verifiedIdSerializer.serialize(verifiedId: MockVerifiedId(id: "", issuedOn: Date()))
    }
}
