/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// This enum is used to return common errors in a standardized format.
/// Please use this to create any errors thrown that could be surfaced outside of the Library.
enum VerifiedIdErrors {
    
    /// Common Error Codes.
    struct ErrorCode {
        static let NetworkingError = "networking_error"
        static let RequirementNotMet = "requirement_not_met"
        static let UnspecifiedError = "unspecified_error"
    }
    
    /// Common Errors in Alphabetical Order.
    case NetworkingError(message: String, correlationId: String, statusCode: String? = nil, innerError: Error? = nil)
    case RequirementNotMet(message: String)
    case UnspecifiedError(error: Error)
    
    /// Mapping of the common error to value with given properties.
    var error: VerifiedIdError {
        switch self {
        case .RequirementNotMet(let message):
            return RequirementNotMetError(message: message, code: ErrorCode.RequirementNotMet)
        case .NetworkingError(message: let message,
                              correlationId: let correlationId,
                              statusCode: let statusCode,
                              innerError: let error):
            return VerifiedIdNetworkingError(message: message,
                                             code: ErrorCode.NetworkingError,
                                             correlationId: correlationId,
                                             statusCode: statusCode,
                                             innerError: error)
        case .UnspecifiedError(error: let error):
            return UnspecifiedVerifiedIdError(error: error)
        }
    }
}

// MARK: Common Errors

/// Thrown when a requirement such as VerifiedIdRequirement is not properly met.
class RequirementNotMetError: VerifiedIdError { }

/// Wraps any error that is not caught by another VerifiedIdError before being returned outside library.
class UnspecifiedVerifiedIdError: VerifiedIdError {
    
    let error: Error
    
    init(error: Error) {
        self.error = error
        super.init(message: "Unspecified Error",
                   code: VerifiedIdErrors.ErrorCode.UnspecifiedError)
    }
    
    private enum CodingKeys: String, CodingKey {
        case message, code, correlationId, error
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(describing: error), forKey: .error)
        try super.encode(to: encoder)
    }
}

/// Thrown when there is a Networking Error within the library.
class VerifiedIdNetworkingError: VerifiedIdError {
    
    let statusCode: String?
    let innerError: Error?
    let retryable: Bool
    
    init(message: String,
         code: String,
         correlationId: String? = nil,
         statusCode: String? = nil,
         innerError: Error? = nil,
         retryable: Bool = false) {
        self.statusCode = statusCode
        self.innerError = innerError
        self.retryable = retryable
        super.init(message: message, code: code, correlationId: correlationId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case message, code, correlationId, statusCode, innerError, retryable
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(String(describing: innerError), forKey: .innerError)
        try container.encode(retryable, forKey: .retryable)
        try super.encode(to: encoder)
    }
}
