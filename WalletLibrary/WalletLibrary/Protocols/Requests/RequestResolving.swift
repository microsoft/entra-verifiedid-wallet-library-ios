/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that conforms to this protocol can resolve a raw request from a request input.
 * It should be specific to a certain type of request handler and input type.
 */
protocol RequestResolving {
    
    var preferHeaders: [String] { get set }
    
    /// Whether or not the object can resolve the given input.
    func canResolve(input: VerifiedIdRequestInput) -> Bool
    
    /// Resolve the raw request from the given input.
    func resolve(input: VerifiedIdRequestInput) async throws -> Any
}
