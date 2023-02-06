/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdClientError: Error {
    case TODO(message: String)
    case protocolNotSupported
}

/**
 * Verified Id Client is used to create requests and is configured using the VerifiedIdClientBuilder.
 */
public class VerifiedIdClient {
    
    private let resolverFactory: RequestResolverFactory
    
    private let requestHandlerFactory: RequestHandlerFactory
    
    private let configuration: VerifiedIdClientConfiguration
    
    /// TODO: configure client using builder.
    init(configuration: VerifiedIdClientConfiguration,
         resolverFactory: RequestResolverFactory,
         requestHandlerFactory: RequestHandlerFactory) {
        self.configuration = configuration
        self.resolverFactory = resolverFactory
        self.requestHandlerFactory = requestHandlerFactory
    }
    
    /// Creates either an issuance or presentation request from the input.
    public func createVerifiedIdRequest(from input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest {
        let resolver = try resolverFactory.makeResolver(from: input)
        let requestHandler = try requestHandlerFactory.makeHandler(from: resolver)
        return try await requestHandler.handleRequest(input: input, using: resolver)
    }
}

public class URLInput: VerifiedIdClientInput {
    
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
}

public class DataInput: VerifiedIdClientInput {
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
}

protocol RequestResolver {
    
    func canResolve(using handler: RequestHandler) -> Bool
    
    func canResolve(input: VerifiedIdClientInput) -> Bool
    
    func resolve(input: VerifiedIdClientInput, using params: [AdditionalRequestParams]) async throws -> RawRequest
}

protocol RequestHandler {
    
    func handleRequest(input: VerifiedIdClientInput, using resolver: RequestResolver) async throws -> any VerifiedIdRequest
}

class RequestResolverFactory {
    
    var resolvers: [RequestResolver] = []
    
    init() { }
    
    func makeResolver(from input: VerifiedIdClientInput) throws -> any RequestResolver {
        
        let resolver = resolvers.filter {
            $0.canResolve(input: input)
        }.first!
        
        return resolver
    }
}

class RequestHandlerFactory {
    
    var requestHandlers: [RequestHandler] = []
    
    init() { }
    
    func makeHandler(from resolver: RequestResolver) throws -> RequestHandler {
        
        let handler = requestHandlers.filter {
            resolver.canResolve(using: $0)
        }.first!
        
        return handler
    }
}

class OpenIdRequestHandler: RequestHandler {
    
    let configuration: VerifiedIdClientConfiguration
    
    var processors: [RequestProcessor] = [OpenIdJWTV1Processor()]
    
    init(configuration: VerifiedIdClientConfiguration) {
        self.configuration = configuration
    }
    
    func handleRequest(input: VerifiedIdClientInput,
                       using resolver: RequestResolver) async throws -> any VerifiedIdRequest {
        
        let additionalParams = getAdditionalRequestParams()
        
        let rawRequest = try await resolver.resolve(input: input, using: additionalParams)
        
        let supportedProcessor = processors.filter {
            $0.canProcess(rawRequest: rawRequest)
        }.first
        
        guard let request = try await supportedProcessor?.process(rawRequest: rawRequest) else {
            throw VerifiedIdClientError.TODO(message: "better error handling")
        }
        
        return request
    }
    
    private func getAdditionalRequestParams() -> [AdditionalRequestParams] {
        /// Use Processors to configure params
        return processors.map { $0.requestParams }
    }
}

protocol RawRequest {
    var raw: Data { get }
}

class OpenIdJWTV1Processor: RequestProcessor {
    
    let requestParams: AdditionalRequestParams = OpenIdRequestParams()
    
    func canProcess(rawRequest: RawRequest) -> Bool {
        
        if rawRequest is OpenIdURLRequest {
            return true
        }
        
        return false
    }
    
    func process(rawRequest: RawRequest) async throws -> any VerifiedIdRequest {
        
        guard let openIdRequest = rawRequest as? OpenIdURLRequest else {
            throw VerifiedIdClientError.TODO(message: "not an open id url request")
        }
        
        print(openIdRequest.presentationRequest)
        
        return VerifiedIdIssuanceRequest(style: MockRequesterStyle(requester: openIdRequest.presentationRequest.content.registration?.clientName ?? "requester"),
                                         requirement: SelfAttestedClaimRequirement(encrypted: false,
                                                                                   required: true,
                                                                                   claim: "test claim"),
                                         rootOfTrust: RootOfTrust(verified: true, source: "test source"))
    }
    
    
}

protocol AdditionalRequestParams {
    
}

struct OpenIdRequestParams: AdditionalRequestParams {
    let supportedProtocolVersions: [String] = ["jwt"]
}

protocol RequestProcessor {
    
    var requestParams: AdditionalRequestParams { get }
    
    func canProcess(rawRequest: RawRequest) -> Bool
    
    func process(rawRequest: RawRequest) async throws -> any VerifiedIdRequest
}
