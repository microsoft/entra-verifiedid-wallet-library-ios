/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Cryptopgraphic Operations needed for verification.
public protocol Hashing {
    
    /// Sign a message using a specific secret, and return the signature.
    func hash(data: Data) -> Data
}
