/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Representation of a Raw Open Id Request.
 * Object that conforms to this protocol must be able to map to VerifiedIdRequestContent.
 */
protocol OpenIdRawRequest: Mappable where T == PresentationRequestContent 
{
    var type: RequestType { get }
    
    /// The DID of the verifier.
    var authority: String { get }
    
    /// The nonce on the request.
    var nonce: String? { get }
    
    var primitiveClaims: [String: Any]? { get }
}
