/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An internal object that describes an access token already prefilled needed for a request.
 */
class PrefilledAccessTokenRequirement: InternalAccessTokenRequirement
{
    public var required: Bool = true
    
    var accessToken: String?
    
    init(accessToken: String)
    {
        self.accessToken = accessToken
    }
    
    public func validate() -> VerifiedIdResult<Void>
    {
        return VerifiedIdResult.success(())
    }
    
    func serialize<T>(protocolSerializer: RequestProcessorSerializing,
                      verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T?
    {
        throw VerifiedIdError(message: "Serialization not enabled for issuance",
                              code: "unsupported_serialization_method")
    }
}
