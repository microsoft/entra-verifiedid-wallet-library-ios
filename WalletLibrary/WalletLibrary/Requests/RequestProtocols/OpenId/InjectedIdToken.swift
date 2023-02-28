/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
<<<<<<<< HEAD:WalletLibrary/WalletLibrary/Requests/RequestProtocols/OpenId/InjectedIdToken.swift
 * An object that represents an id token that is injected from a presentation request into an issuance request.
 */
struct InjectedIdToken {
    let rawToken: String
    
    let pin: PinRequirement?
========
 * Protocol defines the behavior of taking a url and resolving a manifest.
 * For example, it is used as a wrapper to wrap the VC SDK get contract method.
 */
protocol ManifestResolver {
    /// Fetches and validates the manifest.
    func resolve(with url: URL) async throws -> any RawManifest
>>>>>>>> dev:WalletLibrary/WalletLibrary/Protocols/Requests/Manifest/ManifestResolver.swift
}
