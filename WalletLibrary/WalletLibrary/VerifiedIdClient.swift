/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public enum VerifiedIdClientError: Error {
    case notImplemented
    case protocolNotSupported
}

public class VerifiedIdClient {
    
    private let configuration: VerifiedIdClientConfiguration
    
    init(builder: VerifiedIdClientBuilder) {
        self.configuration = ClientConfiguration(logConsumer: builder.logConsumer,
                                                 protocolConfigurations: builder.protocolConfigurations)
    }
    
    public func createVerifiedIdRequest(from input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest {
        
        let supportedProtocolConfiguration = configuration.protocolConfigurations.filter {
            $0.supportedInputType == type(of: input)
        }.first
        
        guard let supportedProtocolConfiguration = supportedProtocolConfiguration else {
            throw VerifiedIdClientError.protocolNotSupported
        }
        
        let request = supportedProtocolConfiguration.protocolHandler.handle(input: input, with: configuration)
        return request
    }
}

class ProtocolConfiguration {
    
    let protocolHandler: ProtocolHandler
    
    let supportedInputType: VerifiedIdClientInput.Type
    
    init(protocolHandler: ProtocolHandler, supportedInputType: VerifiedIdClientInput.Type) {
        self.protocolHandler = protocolHandler
        self.supportedInputType = supportedInputType
    }
}

protocol ProtocolHandler {
    func handle(input: VerifiedIdClientInput, with configuration: VerifiedIdClientConfiguration) -> any VerifiedIdRequest
}

class SIOPProtocolHandler: ProtocolHandler {
    func handle(input: VerifiedIdClientInput,
                with configuration: VerifiedIdClientConfiguration) -> any VerifiedIdRequest {
        return SIOPV1IssuanceRequest(input: input)
    }
}
