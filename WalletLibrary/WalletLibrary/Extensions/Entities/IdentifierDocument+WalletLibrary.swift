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
    /// Looks up a verification method's JWK by `id`. Hardened lookup requires a `did` and verifies
    /// that the method's `id`/`controller` belongs to it. The `DisableResolverHardening` preview
    /// feature restores the legacy `id`-only lookup.
    func getJWK(id: String, forDID did: String?, configuration: LibraryConfiguration) -> JWK?
    {
        guard let publicKeys = verificationMethod else
        {
            return nil
        }

        if configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.DisableResolverHardening) {
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
