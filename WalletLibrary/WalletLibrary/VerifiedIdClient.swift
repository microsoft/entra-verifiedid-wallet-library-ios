/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdClientError: Error {
    case TODO(message: String)
    case protocolNotSupported
}

/**
 * This interface handles a user flow for either presentation or issuance using the configuration from the builder.
 */
public class VerifiedIdClient {
    
    private let configuration: VerifiedIdClientConfiguration
    
    init(builder: VerifiedIdClientBuilder) {
        self.configuration = ClientConfiguration(logConsumer: builder.logConsumer,
                                                 requestProtocolMappings: builder.requestProtocolMappings)
    }
    
    /// Creates either an issuance or presentation request from the input.
    public func createVerifiedIdRequest(from input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest {
        
        let supportedRequestProtocol = configuration.requestProtocolMappings.filter {
            $0.canHandle(input: input)
        }.first
        
        guard let supportedRequestProtocol = supportedRequestProtocol else {
            throw VerifiedIdClientError.protocolNotSupported
        }
        
        let request = supportedRequestProtocol.protocolHandler.handle(input: input, with: configuration)
        return request
    }
}
