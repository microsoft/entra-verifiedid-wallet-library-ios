/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of resolving the Root of Trust (aka Linked Domain Result).
 */
protocol RootOfTrustResolver
{
    func resolve(using identifier: Any) async throws -> RootOfTrust
}
