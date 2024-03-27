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
    
    var primitiveClaims: [String: Any]? { get }
    
    var nonce: String? { get }
    
    var state: String? { get }
    
    var issuer: String? { get }
    
    /// Should only be one definition Id per request.
    var definitionId: String? { get }
}
