/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct VerifiablePresentationDescriptor: Codable 
{
    private struct Constants
    {
        static let Context = "https://www.w3.org/2018/credentials/v1"
        static let VerifiablePresentation = "VerifiablePresentation"
    }
    
    let context: [String]
    
    let type: [String]
    
    let verifiableCredential: [String]
    
    init(context: [String] = [Constants.Context],
         type: [String] = [Constants.VerifiablePresentation],
         verifiableCredential: [String])
    {
        self.context = context
        self.type = type
        self.verifiableCredential = verifiableCredential
    }
    
    enum CodingKeys: String, CodingKey 
    {
        case context = "@context"
        case type, verifiableCredential
    }
}
