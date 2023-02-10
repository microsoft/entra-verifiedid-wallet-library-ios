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
    
    let configuration: LibraryConfiguration
    
    let requestResolverFactory: RequestResolverFactory
    
    let requestHandlerFactory: RequestHandlerFactory
    
    init(requestResolverFactory: RequestResolverFactory,
         requestHandlerFactory: RequestHandlerFactory,
         configuration: LibraryConfiguration) {
        self.requestResolverFactory = requestResolverFactory
        self.requestHandlerFactory = requestHandlerFactory
        self.configuration = configuration
    }
    
    /// Creates either an issuance or presentation request from the input.
    public func createVerifiedIdRequest(from input: VerifiedIdRequestInput) async throws -> any VerifiedIdRequest {
        let resolver = try requestResolverFactory.getResolver(from: input)
        let rawRequest = try await resolver.resolve(input: input)
        let handler = try requestHandlerFactory.getHandler(from: resolver)
        return try await handler.handleRequest(from: rawRequest)
    }
}
