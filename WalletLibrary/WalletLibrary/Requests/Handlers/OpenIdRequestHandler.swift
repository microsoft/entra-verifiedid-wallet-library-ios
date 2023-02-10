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
    
    private let contractResolver: ContractResolver
    
    init(contractResolver: ContractResolver,
         configuration: LibraryConfiguration) {
        self.contractResolver = contractResolver
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
        let content = try configuration.mapper.map(request)
        
        if let requirement = content.requirement as? VerifiedIdRequirement,
           let issuanceInput = requirement.issuanceOptions.first {
            
            let request = try await contractResolver.resolve(input: issuanceInput)
            let issuanceContent = try configuration.mapper.map(request)
            return OpenIdIssuanceRequest(content: content, configuration: configuration)
        }
        
        throw VerifiedIdClientError.TODO(message: "implement")
    }
    
    private func handlePresentationRequest(from request: any OpenIdRawRequest) throws -> any VerifiedIdPresentationRequest {
        let content = try configuration.mapper.map(request)
        return OpenIdPresentationRequest(content: content, configuration: configuration)
    }
}

class OpenIdIssuanceRequest: VerifiedIdIssuanceRequest {
    
    var style: RequesterStyle
    
    var requirement: Requirement
    
    var rootOfTrust: RootOfTrust
    
    private let configuration: LibraryConfiguration
    
    init(content: VerifiedIdRequestContent, configuration: LibraryConfiguration) {
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.configuration = configuration
    }
    
    func isSatisfied() -> Bool {
        return false
    }
    
    func complete() async -> Result<any VerifiedIdRequest, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    func cancel(message: String?) -> Result<Void, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    
}
