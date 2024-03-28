/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of processing a signed credential metadata.
 */
protocol SignedCredentialMetadataProcessing
{
    func process(signedMetadata: String,
                 credentialIssuer: String) async throws -> RootOfTrust
}
