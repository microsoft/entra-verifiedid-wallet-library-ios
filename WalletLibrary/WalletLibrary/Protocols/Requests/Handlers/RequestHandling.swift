/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that can handle an input where the request can be resolved by a request resolver and
 * then processed, validated and mapped to a verified id request. A conforming object is request protocol specific.
 */
protocol RequestHandling {
    associatedtype RawRequest
    
    /// Validate and map an input to a verified id request.
    func handleRequest(from: RawRequest) async throws -> any VerifiedIdRequest
}
