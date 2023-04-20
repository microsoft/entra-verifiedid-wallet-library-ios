/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of a Input Descriptor Mapping Object inside of a Presentation Submission.
 *
 * @see [Presentation Exchange Spec](https://identity.foundation/presentation-exchange/#presentation-submission)
 */
public struct NestedInputDescriptorMapping: Codable {
    
    /// The value of this property MUST be a string that matches the id property of the Input Descriptor
    /// in the Presentation Definition that this Presentation Submission is related to.
    public let id: String
    
    /// The value of this property MUST be a string that matches one of the Claim Format Designation.
    /// This denotes the data format of the Claim. (ex. jwt_vc).
    public let format: String
    
    /// The value of this property MUST be a JSONPath string expression.
    /// The path property indicates the Claim submitted in relation to the identified Input Descriptor,
    /// when executed against the top-level of the object the Presentation Submission is embedded within.
    public let path: String
}
