/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol TokenSigning {
     
    func sign<T>(token: JwsToken<T>, withSecret secret: VCCryptoSecret) throws -> Signature
    
    func getPublicJwk(from secret: VCCryptoSecret, withKeyId keyId: String) throws -> ECPublicJwk
}
