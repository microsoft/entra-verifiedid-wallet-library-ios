//
//  Copyright (C) Microsoft Corporation. All rights reserved.
//

/**
 * This protocol defines an object that can be used to inject correlation headers into all the network calls in the library.
 * The value will be reset at the start of each flow and each correlation header will be updated for each network call made
 * through out the flow.
 *
 * To use this feature, create a class that conforms to the protocol. A library such as the `CorrelationVector` Pod
 * by Microsoft (https://github.com/microsoft/CorrelationVector) can be used to help with the implementation.
 * Then inject an instance of the class into the `VerifiedIdClient` using the `VerifiedIdClientBuilder`.
 */
public protocol VerifiedIdCorrelationHeader {
    
    /// The name of the header (i.e. ms-cv).
    var name: String { get }
    
    /// The value of the header (i.e. some random UUID defined by Correlation Vector v2.1).
    var value: String { get }
    
    /// Updates the Correlation Header Value before each network call.
    func update()
    
    /// Resets the Correlation Header Value before each request flow begins.
    func reset()
}
