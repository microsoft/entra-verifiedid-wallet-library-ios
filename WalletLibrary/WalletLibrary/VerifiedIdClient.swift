/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
    public func createRequest(from input: VerifiedIdRequestInput) async -> VerifiedIdResult<any VerifiedIdRequest> {
        
        // Reset the correlation header before each flow begins.
        self.configuration.networking.resetCorrelationHeader()
        
        return await VerifiedIdResult<VerifiedId>.getResult {
            let resolver = try self.requestResolverFactory.getResolver(from: input)
            let rawRequest = try await resolver.resolve(input: input)
            let handler = try self.requestHandlerFactory.getHandler(from: rawRequest)
            return try await handler.handle(rawRequest: rawRequest)
        }
    }
    
    /// Encode a VerifiedId into Data.
    public func encode(verifiedId: VerifiedId) -> VerifiedIdResult<Data> {
        do {
            let encodedVerifiedId = try configuration.verifiedIdEncoder.encode(verifiedId: verifiedId)
            return VerifiedIdResult.success(encodedVerifiedId)
        } catch {
            return VerifiedIdErrors.MalformedInput(error: error).result()
        }
    }
    
    /// Decode raw Data and return a VerifiedId.
    public func decodeVerifiedId(from raw: Data) -> VerifiedIdResult<VerifiedId> {
        do {
            let verifiedId = try configuration.verifiedIdDecoder.decode(from: raw)
            return VerifiedIdResult.success(verifiedId)
        } catch {
            return VerifiedIdErrors.MalformedInput(error: error).result()
        }
    }
}
