//
//  Copyright (C) Microsoft Corporation. All rights reserved.
//

/**
 * Protocol for adding Correlation Headers to network calls.
 */
public protocol VerifiedIdCorrelationHeader {
    
    /// The name of the header (i.e. ms-cv).
    var name: String { get }
    
    /// The value of the header (i.e. some random UUID).
    var value: String { get }
    
    /// Updates the Correlation Header Value before each network call.
    func update()
    
    /// Resets the Correlation Header Value before each request flow begins.
    func reset()
}
