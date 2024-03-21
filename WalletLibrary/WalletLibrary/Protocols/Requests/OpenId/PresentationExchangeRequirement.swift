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
    /// The id of the presentationDescriptior's input_descriptor object. This is required for forming the input descriptor's submission map.
    var inputDescriptorId: String { get }
    
    /// Specifies the output format of the credential that fulfills this requirement.
    var format: PresentationExchangeVerifiedIdFormat { get }
    
    /// Optional list of other input descriptor IDs that this submission should not be presented with in the same cryptographic proof.
    var exclusivePresentationWith: [String]? { get set }

}
