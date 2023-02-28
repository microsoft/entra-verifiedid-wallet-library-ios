/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol defines the behavior of given generic request, requests a Verifiable Credential from an issuer.
 * For example, it is used as a wrapper to wrap the VC SDK send response method.
 */
protocol VerifiableCredentialRequester {
    
    /// Given generic request,  requests a raw Verified Id from an issuer.
    func send<Request>(request: Request) async throws -> VerifiableCredential
}
