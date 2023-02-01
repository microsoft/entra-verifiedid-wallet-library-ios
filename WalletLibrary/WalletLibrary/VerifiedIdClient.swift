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
    
    private let builder: VerifiedIdClientBuilder
    
    init(builder: VerifiedIdClientBuilder) {
        self.builder = builder
    }
    
    /// Creates either an issuance or presentation request from the input.
    public func createVerifiedIdRequest(from input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest {
        throw VerifiedIdClientError.TODO(message: "implement create request")
    }
}
