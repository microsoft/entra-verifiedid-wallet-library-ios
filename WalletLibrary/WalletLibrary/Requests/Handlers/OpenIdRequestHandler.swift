/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum OpenIdRequestHandlerError: Error {
    case unsupportedRawRequestType
}

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
    func handleRequest<RawRequest>(from request: RawRequest) async throws -> any VerifiedIdRequest {
        
        guard let request = request as? any OpenIdRawRequest else {
            throw OpenIdRequestHandlerError.unsupportedRawRequestType
        }
        
        if request.type == .Issuance {
            return try await handleIssuanceRequest(from: request)
        }
        
        return try handlePresentationRequest(from: request)
    }
    
    private func handleIssuanceRequest(from request: any OpenIdRawRequest) async throws -> any VerifiedIdIssuanceRequest {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
    
    private func handlePresentationRequest(from request: any OpenIdRawRequest) throws -> any VerifiedIdPresentationRequest {
        let content = try configuration.mapper.map(request)
        return OpenIdPresentationRequest(content: content, configuration: configuration)
    }
}
