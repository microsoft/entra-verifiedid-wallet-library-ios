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
            $0.supportedInput.contains {
                $0 == type(of: input)
            }
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
    
    let supportedInput: [VerifiedIdClientInput.Type]
    
    init(protocolHandler: ProtocolHandler, supportedInput: [VerifiedIdClientInput.Type]) {
        self.protocolHandler = protocolHandler
        self.supportedInput = supportedInput
    }
}

protocol ProtocolHandler {
    func handle(input: VerifiedIdClientInput, with configuration: VerifiedIdClientConfiguration) -> any VerifiedIdRequest
}

class SIOPURLInput: VerifiedIdClientInput {
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
}
