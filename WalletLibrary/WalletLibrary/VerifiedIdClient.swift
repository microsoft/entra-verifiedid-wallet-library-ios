/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdClientError: Error {
    case TODO(message: String)
}

/**
 * Verified Id Client is used to create requests and is configured using the VerifiedIdClientBuilder.
 */
public class VerifiedIdClient {
    
    let configuration: LibraryConfiguration
    
    let requestResolverFactory: RequestResolverFactory
    
    let requestHandlerFactory: RequestHandlerFactory
    
    let verifiedIdDecoder: VerifiedIdDecoder = VerifiedIdDecoder()
    
    let verifiedIdEncoder: VerifiedIdEncoder = VerifiedIdEncoder()
    
    init(requestResolverFactory: RequestResolverFactory,
         requestHandlerFactory: RequestHandlerFactory,
         configuration: LibraryConfiguration) {
        self.requestResolverFactory = requestResolverFactory
        self.requestHandlerFactory = requestHandlerFactory
        self.configuration = configuration
    }
    
    /// Creates either an issuance or presentation request from the input.
    public func createVerifiedIdRequest(from input: VerifiedIdRequestInput) async -> Result<any VerifiedIdRequest, Error> {
        do {
            let resolver = try requestResolverFactory.getResolver(from: input)
            let rawRequest = try await resolver.resolve(input: input)
            let handler = try requestHandlerFactory.getHandler(from: resolver)
            let request = try await handler.handleRequest(from: rawRequest)
            return Result.success(request)
        } catch {
            return Result.failure(error)
        }
    }
    
    public func encode(verifiedId: VerifiedId) -> Result<Data, Error> {
        do {
            let encodedVerifiedId = try configuration.verifiedIdEncoder.encode(verifiedId: verifiedId)
            return Result.success(encodedVerifiedId)
        } catch {
            return Result.failure(error)
        }
    }
    
    public func decodeVerifiedId(from raw: Data) -> Result<VerifiedId, Error> {
        do {
            let verifiedId = try configuration.verifiedIdDecoder.decode(from: raw)
            return Result.success(verifiedId)
        } catch {
            return Result.failure(error)
        }
    }
}
