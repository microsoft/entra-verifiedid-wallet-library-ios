/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/**
 * POSTs a CollectionsQuery message to an issuer's IdentityHub to fetch a StatusList2021 credential.
 *
 * Used by older Entra Verified ID credentials whose `credentialStatus` is a `urn:uuid:` or
 * `did:`-relative reference rather than a direct HTTPS URL. The body is the pre-encoded
 * CollectionsQuery JSON; the response (a hub envelope) is returned verbatim as `Data`.
 */
struct CollectionsQueryPostOperation: WalletLibraryPostOperation {

    typealias RequestBody = Data
    typealias ResponseBody = Data
    typealias Encoder = StatusListRawDataEncoder
    typealias Decoder = StatusListResponseDecoder

    var encoder = StatusListRawDataEncoder()
    var decoder = StatusListResponseDecoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: VerifiedIdCorrelationHeader?

    init(requestBody: Data,
         url: URL,
         additionalHeaders: [String: String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?) throws {
        self.urlSession = urlSession
        self.correlationVector = correlationVector
        self.urlRequest = URLRequest(url: url)
        self.urlRequest.httpMethod = Constants.POST
        self.urlRequest.httpBody = requestBody
        self.urlRequest.setValue(Constants.JSON, forHTTPHeaderField: Constants.CONTENT_TYPE)
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}

/// Passes the pre-encoded request body through unchanged; the CollectionsQuery JSON is built by hand.
struct StatusListRawDataEncoder: Encoding {
    func encode(value: Data) throws -> Data {
        return value
    }
}
