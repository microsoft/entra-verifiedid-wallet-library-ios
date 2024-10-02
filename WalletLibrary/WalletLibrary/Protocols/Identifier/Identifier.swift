/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Manages all of the operations for Identifiers including fetching and storing.
protocol VerifiedIdIdentifier
{
    var id: String { get }
    
    var algorithm: String { get }
    
    var method: String { get }
    
    var keyReference: String { get }
    
    func sign(message: Data) throws -> Data
}

class KeychainIdentifier: VerifiedIdIdentifier
{
    let id: String
    
    let algorithm: String
    
    let method: String
    
    let keyReference: String
    
    private let cryptoOperations: CryptoOperations
    
    private let keyReferenceSecret: any VCCryptoSecret
    
    init(id: String, 
         algorithm: String,
         method: String,
         keyReference: String,
         keyReferenceSecret: any VCCryptoSecret,
         cryptoOperations: CryptoOperations)
    {
        self.id = id
        self.algorithm = algorithm
        self.method = method
        self.keyReference = keyReference
        self.keyReferenceSecret = keyReferenceSecret
        self.cryptoOperations = cryptoOperations
    }
    
    func sign(message: Data) throws -> Data
    {
        try cryptoOperations.sign(message: message,
                                  usingSecret: keyReferenceSecret,
                                  algorithm: algorithm)
    }
}

