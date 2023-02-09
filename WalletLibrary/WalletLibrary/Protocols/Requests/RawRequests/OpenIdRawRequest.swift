/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Representation of a Raw Open Id Request.
protocol OpenIdRawRequest: Mappable where T == VerifiedIdRequestContent {
    
    var type: RequestType { get }
    
    var raw: Data? { get }
}

protocol VerifiedIdRequestContent {
    
    var style: RequesterStyle { get }
    
    var requirement: Requirement { get }
    
    var rootOfTrust: RootOfTrust { get }
    
}

enum RequestType {
    case Presentation
    case Issuance
}
