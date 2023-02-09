/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Handles a raw Open Id request and configures a VeriifedIdRequest object.
 * Post Private Preview TODO: add processors to support multiple profiles of open id.
 */
struct OpenIdRequestHandler: RequestHandling {
    
    private let configuration: LibraryConfiguration
    
    init(configuration: LibraryConfiguration) {
        self.configuration = configuration
    }
    
    /// Create a VeriifiedIdRequest based on the Open Id raw request given.
    func handleRequest(from request: any OpenIdRawRequest) async throws -> any VerifiedIdRequest {
        
        if request.type == .Issuance {
            return try await handleIssuanceRequest(from: request)
        }
        
        return try await handlePresentationRequest(from: request)
    }
    
    private func handleIssuanceRequest(from request: any OpenIdRawRequest) async throws -> any VerifiedIdIssuanceRequest {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
    
    private func handlePresentationRequest(from request: any OpenIdRawRequest) async throws -> any VerifiedIdPresentationRequest {
        let content = try configuration.mapper.map(request)
        return OpenIdPresentationRequest(content: content, configuration: configuration)
    }
}
