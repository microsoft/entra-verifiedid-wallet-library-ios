/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol RequestProtocolMapping {
    
    var protocolHandler: RequestProtocolHandler { get }
    
    var supportedInputType: VerifiedIdClientInput.Type { get }
    
    func canHandle(input: VerifiedIdClientInput) -> Bool
}
