/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol VerifiedIdClientConfiguration {
    var logConsumer: WalletLibraryLogConsumer? { get }
    
    var requestProtocolMappings: [RequestProtocolMapping] { get }
}
