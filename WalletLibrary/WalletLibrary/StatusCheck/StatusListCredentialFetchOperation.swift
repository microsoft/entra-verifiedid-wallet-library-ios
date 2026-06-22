/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/**
 * Fetches a StatusList2021 credential (a signed JWT) directly from an issuer's HTTPS endpoint —
 * the `statusListCredential` URL on a credential's `credentialStatus` entry. The body is returned
 * verbatim as `Data` so the caller can parse it as a compact JWS.
 */
struct StatusListCredentialFetchOperation: WalletLibraryFetchOperation {

    typealias ResponseBody = Data
    typealias Decoder = StatusListResponseDecoder

    var decoder = StatusListResponseDecoder()
    var urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: VerifiedIdCorrelationHeader?

    init(url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?) {
        self.urlSession = urlSession
        self.urlRequest = URLRequest(url: url)
        self.correlationVector = correlationVector
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}

/// Returns the raw response bytes unchanged; the status list credential is a JWT, not JSON.
struct StatusListResponseDecoder: Decoding {
    func decode(data: Data) throws -> Data {
        return data
    }
}
