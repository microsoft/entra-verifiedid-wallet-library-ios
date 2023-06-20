/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Allows a different way of resolving the root of trust (aka Linked Domain Result)
/// that can be injected into Issuance and Presentation Service.
public protocol RootOfTrustResolver {
    func resolve(did: String) async throws -> LinkedDomainResult
}
