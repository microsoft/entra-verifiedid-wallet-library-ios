/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol PresentationExchangeRequirement
{
    var inputDescriptorId: String { get }
    
    var format: PresentationExchangeVerifiedIdFormat { get }
    
    var exclusivePresentationWith: [String]? { get set }

}

enum PresentationExchangeVerifiedIdFormat {
    case JWT_VC
}
