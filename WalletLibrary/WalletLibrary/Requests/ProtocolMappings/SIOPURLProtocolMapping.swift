/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class SIOPURLProtocolMapping: RequestProtocolMapping {
    
    let protocolHandler: RequestProtocolHandler = SIOPProtocolHandler()
    
    let supportedInputType: VerifiedIdClientInput.Type = URLInput.self
    
    func canHandle(input: VerifiedIdClientInput) -> Bool {
        /// TODO: implement can handle.
        return true
    }
}
