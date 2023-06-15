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
    case MalformedInput(error: Error, correlationId: String? = nil)
    case NetworkingError(message: String, correlationId: String, statusCode: Int? = nil, innerError: Error? = nil)
    case VCNetworkingError(error: NetworkingError)
    case RequirementNotMet(message: String, errors: [Error]? = nil, correlationId: String? = nil)
    case UnspecifiedError(error: Error, correlationId: String? = nil)
    
    /// Mapping of the common error to value with given properties.
    var error: VerifiedIdError {
        switch self {
        case .MalformedInput(let error, let correlationId):
            return MalformedInputError(error: error, correlationId: correlationId)
        case .NetworkingError(message: let message,
                              correlationId: let correlationId,
                              statusCode: let statusCode,
                              innerError: let error):
            return VerifiedIdNetworkingError(message: message,
                                             code: ErrorCode.NetworkingError,
                                             correlationId: correlationId,
                                             statusCode: statusCode,
                                             innerError: error)
        case .VCNetworkingError(error: let error):
            return VerifiedIdNetworkingError(from: error)
        case .RequirementNotMet(let message, let errors, let correlationId):
            return RequirementNotMetError(message: message, errors: errors, correlationId: correlationId)
        case .UnspecifiedError(error: let error, let correlationId):
            return UnspecifiedVerifiedIdError(error: error, correlationId: correlationId)
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
    
    fileprivate init(error: Error, correlationId: String?) {
        self.error = error
        super.init(message: "Malformed Input.",
                   code: VerifiedIdErrors.ErrorCode.MalformedInputError,
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

/// Thrown when a requirement such as VerifiedIdRequirement is not properly met.
class RequirementNotMetError: VerifiedIdError {
    
    let errors: [Error]?
    
    fileprivate init(message: String, errors: [Error]? = nil, correlationId: String?) {
        self.errors = errors
        super.init(message: message,
                   code: VerifiedIdErrors.ErrorCode.RequirementNotMet,
                   correlationId: correlationId)
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
    
    let statusCode: Int?
    let innerError: Error?
    let retryable: Bool
    
    fileprivate init(message: String,
                     code: String,
                     correlationId: String? = nil,
                     statusCode: Int? = nil,
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
    
    convenience init(from vcNetworkingError: NetworkingError, correlationId: String? = nil) {
        
        var message: String = "Unknown Networking Error"
        var statusCode: Int?
        
        switch vcNetworkingError {
        case .badRequest(withBody: _, statusCode: let code):
            message = "Bad Request"
            statusCode = code
        case .forbidden(withBody: _, statusCode: let code):
            message = "Forbidden"
            statusCode = code
        case .notFound(withBody: _, statusCode: let code):
            message = "Not Found"
            statusCode = code
        case .serverError(withBody: _, statusCode: let code):
            message = "Server Error"
            statusCode = code
        case .unauthorized(withBody: _, statusCode: let code):
            message = "Unauthorized"
            statusCode = code
        case .unknownNetworkingError(withBody: _, statusCode: let code):
            statusCode = code
        default:
            statusCode = nil
        }
        
        self.init(message: message,
                  code: VerifiedIdErrors.ErrorCode.NetworkingError,
                  correlationId: correlationId,
                  statusCode: statusCode,
                  innerError: vcNetworkingError,
                  retryable: false)
    }
}
