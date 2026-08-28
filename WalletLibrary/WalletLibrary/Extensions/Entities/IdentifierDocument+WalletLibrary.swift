/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.IdentifierDocument class
 * to get Public JWK with specific ID from document.
 */
extension IdentifierDocument
{
    /// Looks up a verification method's JWK by `id`. When the `HardenedJwkValidation` preview
    /// feature is supported, a `did` is required and the lookup requires the verification
    /// method's `id`/`controller` to belong to it; a `nil` did returns `nil` rather than
    /// silently falling back. When the feature is not supported, matching falls back to the
    /// legacy `id`-only lookup regardless of whether `did` was provided.
    func getJWK(id: String, forDID did: String?, configuration: LibraryConfiguration) -> JWK?
    {
        guard let publicKeys = verificationMethod else
        {
            return nil
        }

        guard configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.HardenedJwkValidation) else {
            return publicKeys.first(where: { $0.id == id })?.publicKeyJwk.toJWK()
        }

        guard let did else {
            return nil
        }

        guard let keyIdentifier = DIDVerificationMethodIdentifier(keyId: did + id) else {
            return nil
        }

        return publicKeys.first(where: { $0.matches(keyIdentifier) })?.publicKeyJwk.toJWK()
    }
}
