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
        let requestHandler = try requestHandlerFactory.makeHandler(from: input)
        return try await requestHandler.handleRequest(input: input)
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
    
    var handler: RequestHandler.Type { get }
    
    func canResolve(input: VerifiedIdClientInput) -> Bool
    
    func resolve(using params: ClientInputParams?) async throws -> Data
}

struct OpenIdURLRequestResolver: RequestResolver {
    
    let handler: RequestHandler.Type = OpenIdRequestHandler.self
    
    func canResolve(input: VerifiedIdClientInput) -> Bool {
        
        guard let input = input as? URLInput else {
            return false
        }
        
        if input.url.scheme == "openid-vc" {
            return true
        }
        
        return false
    }
    
    func resolve(using params: ClientInputParams?) async throws -> Data {
        return Data()
    }
    
}

protocol RequestHandler {
    
    var mappingStrategy: (any RequestResolver)? { get set }
    
    func handleRequest(input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest
}

protocol RequestResolverFactory {
    func makeResolver(from input: VerifiedIdClientInput) throws -> any RequestResolver
}

class RequestHandlerFactory {
    
    var requestHandlers: [RequestHandler] = []
    
    var mappingStrategies: [any RequestResolver] = []
    
    init() { }
    
    func makeHandler(from input: VerifiedIdClientInput) throws -> RequestHandler {
        
        let mappingStrategy = mappingStrategies.filter {
            filter(input: input, using: $0)
        }.first!
        
        var handler = requestHandlers.filter { handler in
            mappingStrategy.handler == type(of: handler)
        }.first!
        
        handler.mappingStrategy = mappingStrategy
        
        return handler
    }
    
    func filter(input: VerifiedIdClientInput, using mappingStrategy: some RequestResolver) -> Bool {
        return mappingStrategy.canResolve(input: input)
    }
}

//class ContractRequestHandler: RequestHandler {
//
//    let configuration: VerifiedIdClientConfiguration
//
//    init(configuration: VerifiedIdClientConfiguration) {
//        self.configuration = configuration
//    }
//
//    func handleRequest(input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest {
//        /// Fetch contract or something
//        throw VerifiedIdClientError.TODO(message: "not implemented")
//    }
//}

class OpenIdRequestHandler: RequestHandler {
    
    let configuration: VerifiedIdClientConfiguration
    
    var processors: [RequestProcessor] = [SIOPV1Processor()]
    
    var mappingStrategy: (any RequestResolver)?
    
    init(configuration: VerifiedIdClientConfiguration) {
        self.configuration = configuration
    }
    
    func handleRequest(input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest {
        
        let clientParams = getClientParams()
        
        let rawRequest = try await mappingStrategy!.resolve(using: clientParams)
        
        let supportedProcessor = processors.filter {
            $0.canProcess(data: rawRequest)
        }.first
        
        guard let request = try await supportedProcessor?.process(data: rawRequest) else {
            throw VerifiedIdClientError.TODO(message: "better error handling")
        }
        
        return request
    }
    
    private func getClientParams() -> ClientInputParams {
        /// Use Processors to configure params
        return MockClientParams(headers: [:])
    }
}

class SIOPV1Processor: RequestProcessor {
    func canProcess(data: Data) -> Bool {
        return true
    }
    
    func process(data: Data) async throws -> any VerifiedIdRequest {
        return VerifiedIdIssuanceRequest(style: MockRequesterStyle(),
                                         requirement: SelfAttestedClaimRequirement(encrypted: false,
                                                                                   required: true,
                                                                                   claim: "test claim"),
                                         rootOfTrust: RootOfTrust(verified: true, source: "test source"))
    }
    
    
}

protocol ClientInputParams {
    
}

struct MockClientParams: ClientInputParams {
    let headers: [String: String]
}

protocol RequestProcessor {
    
    func canProcess(data: Data) -> Bool
    
    func process(data: Data) async throws -> any VerifiedIdRequest
}
