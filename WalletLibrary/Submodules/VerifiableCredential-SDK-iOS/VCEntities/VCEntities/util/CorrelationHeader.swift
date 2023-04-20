//
//  Copyright (C) Microsoft Corporation. All rights reserved.
//

/**
 * Protocol for adding Correlation Headers to network calls.
 */
public protocol CorrelationHeader {
    
    /// the name of the header (i.e. ms-cv)
    var name: String { get }
    
    /// the value of the header (i.e. some random UUID)
    var value: String { get }
    
    /// function that updates the correlation value before each network call.
    func update() -> String
}
