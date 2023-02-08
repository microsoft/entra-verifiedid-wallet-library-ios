/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that conforms to this protocol can resolve a raw request from a request input.
 * It should be specific to a certain type of request handler and input type.
 */
protocol RequestResolving {
    associatedtype RawRequest

    /// Whether or not the object can resolve a raw request that will be handled by the given handler.
    func canResolve(using handler: any RequestHandling) -> Bool
    
    /// Whether or not the object can resolve the given input.
    func canResolve(input: VerifiedIdClientInput) -> Bool
    
    /// Resolve the raw request from the given input.
    func resolve(input: VerifiedIdClientInput) async throws -> RawRequest
}
