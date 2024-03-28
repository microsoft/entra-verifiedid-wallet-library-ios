/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Serializes a Verifiable Credential.
 * Input `VerifiedId` must conform to the `InternalVerifiedId` protocol
 * in order to access the `VerifiableCredential` property that can be serialized into the
 * compact token format.
 */
struct VerifiableCredentialSerializer: VerifiedIdSerializing
{
    func serialize(verifiedId: VerifiedId) throws -> String
    {
        guard let vc = verifiedId as? InternalVerifiedId else
        {
            let message = "Unsupported Verified ID Type during serialization: \(String(describing: type(of: verifiedId)))."
            throw VerifiedIdErrors.MalformedInput(message: message).error
        }
        
        return try vc.raw.serialize()
    }
}
