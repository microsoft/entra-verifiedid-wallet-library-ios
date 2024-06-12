/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a pin that is required.
 */
class OpenId4VCIRetryablePinRequirement: RetryablePinRequirement, InternalAccessTokenRequirement
{
    /// If the requirement is required or not.
    public let required = true
    
    /// The length of the pin to display.
    public let length: Int
    
    /// The type of the pin such as alphanumeric or numeric.
    public let type: String
    
    /// The pin that fulfills the requirement.
    var accessToken: String?
    
    /// The code needed to fetch access token using pin.
    private let code: String
    
    private let configuration: LibraryConfiguration
    
    private let grant: CredentialOfferGrant
    
    init(configuration: LibraryConfiguration,
         code: String,
         grant: CredentialOfferGrant)
    {
        self.configuration = configuration
        self.code = code
        self.grant = grant
        self.length = grant.tx_code?.length ?? -1
        self.type = grant.tx_code?.input_mode ?? "alphanumeric"
    }
    
    /// Returns failure result if requirement is not fulfilled.
    public func validate() -> VerifiedIdResult<Void>
    {
        if accessToken == nil
        {
            return VerifiedIdErrors.RequirementNotMet(message: "Pin has not been set.").result()
        }
        
        return VerifiedIdResult.success(())
    }
    
    /// Fulfill requirement with pin and fetch access token using given pin.
    /// If fails to fetch access token, a new pin can be tried.
    public func fulfill(with pin: String) async -> VerifiedIdResult<Void>
    {
        do
        {
            let resolver = OpenID4VCIPreAuthTokenResolver(configuration: configuration)
            let accessToken = try await resolver.resolve(using: grant, pin: pin)
            self.accessToken = accessToken
            return VerifiedIdResult.success(())
        }
        catch
        {
            let message = "Unable to fetch access token using pin \(pin)."
            return VerifiedIdErrors.RequirementNotMet(message: message,
                                                      errors: [error]).result()
        }
    }
    
    func serialize<T>(protocolSerializer: RequestProcessorSerializing, 
                      verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T?
    {
        throw VerifiedIdError(message: "Serialization not enabled for issuance",
                              code: "unsupported_serialization_method")
    }
}
