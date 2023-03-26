/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PinRequirementError: Error {
    case pinRequirementHasNotBeenFulfilled
}

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
    
    /// The optional salt.
    let salt: String?
    
    /// The pin that fulfills the requirement.
    var pin: String?
    
    init(required: Bool,
         length: Int,
         type: String,
         salt: String?) {
        self.required = required
        self.length = length
        self.type = type
        self.salt = salt
    }
    
    /// Returns Failure Result if requirement is not fulfilled.
    public func validate() -> Result<Void, Error> {
        if pin == nil {
            return Result.failure(PinRequirementError.pinRequirementHasNotBeenFulfilled)
        }
        
        return Result.success(())
    }
    
    /// Fulfill requirement with a pin.
    public func fulfill(with pin: String) {
        self.pin = pin
    }
}
