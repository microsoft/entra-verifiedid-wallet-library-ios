/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a pin that is required.
 */
class OpenId4VCIRetryablePinRequirement: RetryablePinRequirement
{
    /// If the requirement is required or not.
    public let required = true
    
    /// The length of the pin to display.
    public let length: Int
    
    /// The type of the pin such as alphanumeric or numeric.
    public let type: String
    
    let code: String
    
    /// The pin that fulfills the requirement.
    var accessToken: String?
    
    let configuration: LibraryConfiguration
    
    init(configuration: LibraryConfiguration,
         code: String,
         length: Int,
         type: String)
    {
        self.configuration = configuration
        self.length = length
        self.type = type
        self.code = code
    }
    
    /// Returns Failure Result if requirement is not fulfilled.
    public func validate() -> VerifiedIdResult<Void> 
    {
        if accessToken == nil
        {
            return VerifiedIdErrors.RequirementNotMet(message: "Pin has not been set.").result()
        }
        
        return VerifiedIdResult.success(())
    }
    
    /// Fulfill requirement with a pin.
    public func fulfill(with pin: String) async -> VerifiedIdResult<Void>
    {
//        configuration.networking.
        return VerifiedIdResult.success(())
    }
}

public protocol RetryablePinRequirement: Requirement
{
    func fulfill(with pin: String) async -> VerifiedIdResult<Void>
}
