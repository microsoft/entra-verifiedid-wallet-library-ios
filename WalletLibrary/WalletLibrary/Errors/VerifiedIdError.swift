/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Base Error Protocol. Every error that is returned from the library is a VerifiedIdError.
 * Extensions may extend this class.
 */
open class VerifiedIdError: LocalizedError, CustomStringConvertible, Encodable
{
    public let message: String
    public let code: String
    public let correlationId: String?
    
    init(message: String, code: String, correlationId: String? = nil) 
    {
        self.message = message
        self.code = code
        self.correlationId = correlationId
    }
    
    public var description: String {
        if let encodedObject = try? JSONEncoder().encode(self),
           let description = String(data: encodedObject, encoding: .utf8) 
        {
            return description
        }
        
        return "{message: \(message), code: \(code)}"
    }
    
    /// The error description is used on Error protocol to create a description for the error.
    /// It should be set to our custom error description.
    public var errorDescription: String? {
        get {
            return self.description
        }
    }
    
    /// Helper function to wrap error in a VerifiedIdResult.
    func result<T>() -> VerifiedIdResult<T> 
    {
        return VerifiedIdResult(error: self)
    }
}
