/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct PresentationResponse: PropertyIterable {
    
    let idToken: PresentationResponseToken
    
    let vpTokens: [VerifiablePresentation]
    
    let state: String?
    
    init(idToken: PresentationResponseToken,
         vpTokens: [VerifiablePresentation],
         state: String?) {
        self.idToken = idToken
        self.vpTokens = vpTokens
        self.state = state
    }
    
    func encode(to encoder: any Encoder) throws 
    {
        
    }
    
    func allProperties() -> [String : String?] {
        [:]
    }
}
