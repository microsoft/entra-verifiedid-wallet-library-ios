/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// This enum is used to return common errors in a standardized format.
/// Please use this to create any errors thrown that could be surfaced outside of the Library.
enum VerifiedIdErrors {
    
    /// Common Error Codes.
    struct ErrorCode {
        static let MalformedInputError = "malformed_input_error"
        static let NetworkingError = "networking_error"
        static let RequirementNotMet = "requirement_not_met"
        static let UnspecifiedError = "unspecified_error"
        static let UserCanceled = "user_canceled"
    }
    
    /// Common Errors in Alphabetical Order.
    case MalformedInput(error: Error)
    case NetworkingError(message: String, correlationId: String, statusCode: String? = nil, innerError: Error? = nil)
    case RequirementNotMet(message: String, errors: [Error]? = nil)
    case UnspecifiedError(error: Error)
    
    /// Mapping of the common error to value with given properties.
    var error: VerifiedIdError {
        switch self {
        case .MalformedInput(error: let error):
            return MalformedInputError(error: error)
        case .NetworkingError(message: let message,
                              correlationId: let correlationId,
                              statusCode: let statusCode,
                              innerError: let error):
            return VerifiedIdNetworkingError(message: message,
                                             code: ErrorCode.NetworkingError,
                                             correlationId: correlationId,
                                             statusCode: statusCode,
                                             innerError: error)
        case .RequirementNotMet(let message, let errors):
            return RequirementNotMetError(message: message, errors: errors)
        case .UnspecifiedError(error: let error):
            return UnspecifiedVerifiedIdError(error: error)
        }
    }
    
    /// Helper function to wrap error in a VerifiedIdResult.
    func result<T>() -> VerifiedIdResult<T> {
        return error.result()
    }
}

// MARK: Common Errors

/// Thrown when an input such as Data in decoding method is not properly formed.
class MalformedInputError: VerifiedIdError {
    
    let error: Error
    
    fileprivate init(error: Error) {
        self.error = error
        super.init(message: "Malformed Input.",
                   code: VerifiedIdErrors.ErrorCode.MalformedInputError)
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

/// Thrown when a requirement such as VerifiedIdRequirement is not properly met.
class RequirementNotMetError: VerifiedIdError {
    
    let errors: [Error]?
    
    fileprivate init(message: String, errors: [Error]? = nil) {
        self.errors = errors
        super.init(message: message,
                   code: VerifiedIdErrors.ErrorCode.RequirementNotMet)
    }
    
    private enum CodingKeys: String, CodingKey {
        case message, code, correlationId, errors
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(describing: errors), forKey: .errors)
        try super.encode(to: encoder)
    }
}

/// Wraps any error that is not caught by another VerifiedIdError before being returned outside library.
class UnspecifiedVerifiedIdError: VerifiedIdError {
    
    let error: Error
    
    init(error: Error, correlationId: String?) {
        self.error = error
        super.init(message: "Unspecified Error.",
                   code: VerifiedIdErrors.ErrorCode.UnspecifiedError,
                   correlationId: correlationId)
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
    
    fileprivate init(message: String,
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
