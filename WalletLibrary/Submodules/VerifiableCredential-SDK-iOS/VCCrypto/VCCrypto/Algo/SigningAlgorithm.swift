/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct SigningAlgorithm {
    let curve: String
    
    let algorithm: Signing
    
    let supportedSigningOperations: [SupportedSigningOperations]
}

public enum SupportedSigningOperations {
    case Signing
    case Verification
    case GetPublicKey
}
