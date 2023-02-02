/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a pin that is required.
 */
public class PinRequirement: Requirement {
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The length of the pin to display.
    public let length: Int
    
    /// The type of the pin such as alphanumeric or numeric.
    public let type: String
    
    init(required: Bool,
         length: Int,
         type: String) {
        self.required = required
        self.length = length
        self.type = type
    }
    
    public func validate() throws {
        throw VerifiedIdClientError.TODO(message: "implement validate")
    }
}
