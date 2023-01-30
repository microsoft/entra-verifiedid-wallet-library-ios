/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public class VerifiedIdClientBuilder {
    
    var logConsumer: VerifiedIdWalletLogConsumer?
    
    var input: VerifiedIdClientInput?
    
    var resolvedInput: ResolvedInput?

    public init() {
        logConsumer = nil
        input = nil
    }

    public func with(input: VerifiedIdClientInput) -> VerifiedIdClientBuilder
    {
        self.input = input
        return self
    }

    public func build() async throws -> any VerifiedIdClient
    {
        let resolvedInput = await input?.resolve()
        self.resolvedInput = resolvedInput
        
        switch(resolvedInput?.type) {
        case .Issuance:
            if let client = VerifiedIdIssuanceClient(builder: self) {
                return client
            } else {
                throw VerifiedIdClientError.notImplemented
            }
        default:
            throw VerifiedIdClientError.notImplemented
        }
    }

    public func with(logConsumer: VerifiedIdWalletLogConsumer) -> VerifiedIdClientBuilder
    {
        self.logConsumer = logConsumer
        return self
    }

    // MARK: Post Private Preview
    
    /// add a custom identifier document resolver
    public func with(IdentifierDocumentResolverUri: IdentifierDocumentResolver) -> VerifiedIdClientBuilder {
        return self
    }
    
    /// add a verified id repository.
    public func with(verifiedIdRepository: VerifiedIdRepository) -> VerifiedIdClientBuilder {
        return self
    }
}

public enum InputType {
    case Issuance
    case Presentation
}

public protocol VerifiedIdWalletLogConsumer {}

public protocol IdentifierDocumentResolver {}

public protocol VerifiedIdRepository {}
