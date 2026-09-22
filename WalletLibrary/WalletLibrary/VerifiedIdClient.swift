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
    
    let requestHandlerFactory: RequestProcessorFactory

    /// Whether this client successfully selected its built-in did:jwk/ES256 default holder.
    /// False when a legacy fallback or only custom holders were selected.
    /// Throws the original loading error when no default holder could be selected.
    /// This reports selection at build time, not the availability of keychain material at a later time.
    public var isDefaultHolderIdentifierFIPSCompliant: Bool {
        get throws {
            _ = try configuration.identifierFactory.getIdentifier()
            return configuration.isDefaultHolderIdentifierFIPSCompliant
        }
    }
    
    init(requestResolverFactory: RequestResolverFactory,
         requestHandlerFactory: RequestProcessorFactory,
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
            if self.configuration.identifierFactory.identifiers.isEmpty,
               let error = self.configuration.identifierFactory.loadingError {
                throw error
            }
            let resolver = try self.requestResolverFactory.getResolver(from: input)
            let rawRequest = try await resolver.resolve(input: input)
            let handler = try self.requestHandlerFactory.getHandler(from: rawRequest)
            return try await handler.process(rawRequest: rawRequest)
        }
    }
    
    /// Checks whether a `VerifiedId` has been revoked, suspended, or expired.
    ///
    /// Expiry is determined locally from the credential's `expiresOn`; revocation and suspension are
    /// resolved against the issuer's W3C StatusList2021 endpoint. The check is fail-open: any error
    /// or indeterminate result returns `.unknown` and never throws. The presentation/issuance server
    /// remains the authoritative enforcement point.
    public func checkVerifiedIdStatus(_ verifiedId: VerifiedId) async -> VerifiedIdStatus {
        configuration.networking.resetCorrelationHeader()
        let service = StatusCheckService(configuration: configuration)
        return await service.checkStatus(of: verifiedId)
    }

    /// Encode a VerifiedId into Data.
    public func encode(verifiedId: VerifiedId) -> VerifiedIdResult<Data> {
        do {
            let encodedVerifiedId = try configuration.verifiedIdEncoder.encode(verifiedId: verifiedId)
            return VerifiedIdResult.success(encodedVerifiedId)
        } catch {
            let message = "Unable to encode Verified ID."
            return VerifiedIdErrors.MalformedInput(message: message, error: error).result()
        }
    }
    
    /// Decode raw Data and return a VerifiedId.
    public func decodeVerifiedId(from raw: Data) -> VerifiedIdResult<VerifiedId> {
        do {
            let verifiedId = try configuration.verifiedIdDecoder.decode(from: raw)
            return VerifiedIdResult.success(verifiedId)
        } catch {
            let message = "Unable to decode Verified ID."
            return VerifiedIdErrors.MalformedInput(message: message, error: error).result()
        }
    }
}
