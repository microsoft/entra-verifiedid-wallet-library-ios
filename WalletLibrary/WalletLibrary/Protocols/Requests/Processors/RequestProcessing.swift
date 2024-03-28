/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that can handle an input where the request can be resolved by a request resolver and
 * then processed, validated and mapped to a verified id request. A conforming object is request protocol specific.
 */
protocol RequestProcessing: ExtendableRequestProcessing
{
    /// Determines if Request Handler can handle the object.
    func canProcess(rawRequest: Any) -> Bool
    
    /// Validate and map an input to a verified id request.
    func process(rawRequest: Any) async throws -> any VerifiedIdRequest
}

/**
 * A   `RequestProcessor` that is able to be extended using `RequestProcessorExtendable`s. 
 */
public protocol ExtendableRequestProcessing
{
    /**
     * Associated type formed by the RequestProcessor to pass to extensions.
     * note: should only consist of primitive types from the deserializer, but can be more advanced than the handle's rawRequest
     */
     associatedtype RawRequestType
    
    /// Extensions to this RequestProcessor. All extensions should be called after main request processing.
    var requestProcessorExtensions: [any RequestProcessorExtendable] { get set }
}
