/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a pin that is required.
 */
public struct PinRequirement {
    
    /// The length of the pin to display.
    public let length: Int
    
    /// The type of the pin such as alphanumeric or numeric.
    public let type: String
}
