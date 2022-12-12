/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCServices
import VCEntities

public enum VerifiedIdFlowError: Error {
    case Unimplemented
}

/**
 * External Interface/Protocol that handles Issuance and Presentation Flows.
 */
public class VerifiedIdFlow {
     /// User scans QR code/deep-links to app. Request URI contained within QR code, and returns either an Issuance or Presentation Request.
    public func initiate(requestUri: URL) async throws -> Request {
        let request = try await RequestHandler().handle(requestUri: requestUri)
        print(request)
        return request
    }

     /// Returns true if VerifiedIdFlow can handle request uri, else returns false
    public func canHandle(requestUri: URL) -> Bool {
        return false
    }

    /// Dev might choose to fetch contract for use cases like issuance during presentation/notifications without access to a requestUrl but rather just the Contract URL.
    public func initiate(credentialIssuanceParams: CredentialIssuanceParams) async throws -> IssuanceRequest {
        throw VerifiedIdFlowError.Unimplemented
    }
    
    /// Send presentation response to verifier, optional options for persona/did/algorithm extensibility.
//    func complete(response: PresentationResponse, options: PresentationOptions?) async throws -> Void

    /// If there is a user error, or error outside of SDK control, send presentation completion error.
//    func completeWithError(response: PresentationResponse, error: Error) -> Void

    /// Send issuance response to issuer and issuance completion response, optional options for persona/did/algorithm extensibility.
    public func complete(response: IssuanceResponse, options: IssuanceOptions?) async throws -> VerifiedId {
        throw VerifiedIdFlowError.Unimplemented
    }

    /// If there is a user error, or error outside of SDK control, send issuance completion error.
    public func completeWithError(response: IssuanceResponse, error: Error) async throws -> Void {
        throw VerifiedIdFlowError.Unimplemented
    }
}

public struct IssuanceResponse {}

public struct IssuanceOptions {}
