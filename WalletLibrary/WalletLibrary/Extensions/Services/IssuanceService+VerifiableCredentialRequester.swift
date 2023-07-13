/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum IssuanceServiceVCRequesterError: Error {
    case unableToCastIssuanceResponseContainerFromType(String)
    case unableToCastIssuanceCompletionResponseFromType(String)
}
/**
 * An extension of the VCServices.IssuanceService class
 * that wraps send method with a generic send method that conforms to VerifiableCredentialRequester protocol.
 */
extension IssuanceService: VerifiedIdRequester {
    
    /// Sends the issuance response container and if successful, returns a Verifiable Credential.
    /// If unsuccessful, throws an error.
    func send<Request>(request: Request) async throws -> VerifiedId {
        
        guard let issuanceResponseContainer = request as? IssuanceResponseContainer else {
            let requestType = String(describing: request.self)
            throw IssuanceServiceVCRequesterError.unableToCastIssuanceResponseContainerFromType(requestType)
        }
        
        let rawVerifiableCredential = try await send(response: issuanceResponseContainer)
        
        let verifiableCredential = try VCVerifiedId(raw: rawVerifiableCredential,
                                                    from: issuanceResponseContainer.contract)
        return verifiableCredential
    }
    
    func send<IssuanceResult>(result: IssuanceResult, to url: URL) async throws -> Void {
        
        guard let issuanceCompletionResponse = result as? IssuanceCompletionResponse else {
            let resultType = String(describing: result.self)
            throw IssuanceServiceVCRequesterError.unableToCastIssuanceCompletionResponseFromType(resultType)
        }
        
        _ = try await sendCompletionResponse(for: issuanceCompletionResponse, to: url.absoluteString)
    }
}
