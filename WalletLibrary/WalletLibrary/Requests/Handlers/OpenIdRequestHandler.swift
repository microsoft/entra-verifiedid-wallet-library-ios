/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Handles a raw Open Id request and configures a VeriifedIdRequest object.
 */
struct OpenIdRequestHandler: RequestHandling {
    
    /// Create a VeriifiedIdRequest based on the Open Id raw request given.
    /// TODO: post private preview, input needs to be more generic to support multiple profiles of Open Id.
    func handleRequest(from: OpenIdRawRequest) async throws -> any VerifiedIdRequest {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
