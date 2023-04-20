/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif

public protocol TokenVerifying {
    
    func verify<T>(token: JwsToken<T>, usingPublicKey key: JWK) throws -> Bool
}


