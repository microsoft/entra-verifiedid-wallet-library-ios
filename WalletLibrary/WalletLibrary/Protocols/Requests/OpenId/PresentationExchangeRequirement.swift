/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Presentation Exchange Verified ID formats.
 */
enum PresentationExchangeVerifiedIdFormat
{
    case JWT_VC
}

/**
 * Describes properties to be included in a Presentation Exchange Requirement.
 */
protocol PresentationExchangeRequirement
{
    var inputDescriptorId: String { get }
    
    var format: PresentationExchangeVerifiedIdFormat { get }
    
    var exclusivePresentationWith: [String]? { get set }

}
