/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Base Error Protocol. Every error that is returned from the library is a VerifiedIdError.
public protocol VerifiedIdError: Error {
    /// Developer friendly message to explain why error occurred.
    var message: String { get }
    
    /// Error code that can be used to debug.
    var code: String { get }
    
    /// Optional correlationId.
    var correlationId: String? { get }
}

// MARK: Common Error Enum
/// This enum is used to return common errors in a standardized format.
/// Please use this to create any errors thrown that could be surfaced outside of the Library.
enum VerifiedIdCommonError {
    
    /// Common Error Codes.
    struct ErrorCode {
        static let NetworkingError = "networking_error"
        static let RequirementNotMet = "requirement_not_met"
    }
    
    /// Common Errors in Alphabetical Order.
    case NetworkingError(message: String, correlationId: String, statusCode: String? = nil, innerError: Error? = nil)
    case RequirementNotMet(message: String)
    
    /// Mapping of the common error to value with given properties.
    var value: VerifiedIdError {
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
        }
    }
}

// MARK: Common Errors
struct RequirementNotMetError: VerifiedIdError {
    let message: String
    let code: String
    let correlationId: String? = nil
}

struct VerifiedIdNetworkingError: VerifiedIdError {
    let message: String
    let code: String
    let correlationId: String?
    let statusCode: String?
    let innerError: Error?
}
