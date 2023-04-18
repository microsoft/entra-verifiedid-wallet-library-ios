/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif

enum IssuancePinError: Error {
    case unableToEncodeHashInput
}

public struct IssuancePin: Equatable {
    
    let pin: String
    let salt: String?
    
    public init(from pin: String, withSalt salt: String? = nil) {
        self.pin = pin
        self.salt = salt
    }
    
    func hash() throws -> String {
        
        var hashInput: String
        if let nonnilSalt = salt {
            hashInput = nonnilSalt + pin
        } else {
            hashInput = pin
        }
        
        guard let encodedHashInput = hashInput.data(using: .ascii) else {
            throw IssuancePinError.unableToEncodeHashInput
        }
        
        return Sha256().hash(data: encodedHashInput).base64EncodedString()
    }
}

