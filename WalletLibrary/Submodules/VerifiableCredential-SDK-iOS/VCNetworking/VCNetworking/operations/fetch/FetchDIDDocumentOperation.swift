/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum DIDDiscoveryValidation {
    static func discoveryURL(for identifier: String, baseURL: String) throws -> URL {
        try validate(identifier: identifier)

        guard var urlComponents = URLComponents(string: baseURL) else {
            throw malformedInput("Invalid url: \(baseURL).")
        }

        let pathSuffix = urlComponents.path.last == "/" ? identifier : "/" + identifier
        urlComponents.path = urlComponents.path + pathSuffix

        guard let url = urlComponents.url else {
            throw malformedInput("Invalid url: \(urlComponents.string ?? "").")
        }

        return url
    }

    static func validate(document: IdentifierDocument, requestedIdentifier: String) throws {
        guard document.id == requestedIdentifier else {
            throw malformedInput("Resolved Identifier Document does not match the requested DID.")
        }
    }

    private static func validate(identifier: String) throws {
        let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-%:"
        guard !identifier.isEmpty,
              identifier.allSatisfy({ allowedCharacters.contains($0) }) else {
            throw malformedInput("Invalid DID identifier.")
        }

        var candidate = identifier

        for _ in 0..<5 {
            try validateDecodedIdentifier(candidate)

            guard candidate.contains("%") else {
                return
            }

            guard let decoded = candidate.removingPercentEncoding,
                  decoded != candidate else {
                throw malformedInput("Invalid DID identifier.")
            }
            candidate = decoded
        }

        guard !candidate.contains("%") else {
            throw malformedInput("Invalid DID identifier.")
        }
        try validateDecodedIdentifier(candidate)
    }

    private static func validateDecodedIdentifier(_ identifier: String) throws {
        let components = identifier.split(separator: ":", omittingEmptySubsequences: false)
        guard components.count >= 3,
              components[0] == "did",
              !components[1].isEmpty,
              components[1].allSatisfy({ "abcdefghijklmnopqrstuvwxyz0123456789".contains($0) }),
              components.dropFirst(2).allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }),
              !identifier.contains(where: { "/\\?#".contains($0) }) else {
            throw malformedInput("Invalid DID identifier.")
        }
    }

    private static func malformedInput(_ message: String) -> Error {
        VerifiedIdErrors.MalformedInput(message: message).error
    }
}

class FetchDIDDocumentOperation: InternalNetworkOperation {
    typealias ResponseBody = IdentifierDocument
    
    let decoder = DIDDocumentDecoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(withIdentifier identifier: String,
         andCorrelationVector correlationVector: VerifiedIdCorrelationHeader? = nil,
         session: URLSession) throws {
        
        let url = try DIDDiscoveryValidation.discoveryURL(
            for: identifier,
            baseURL: VCSDKConfiguration.sharedInstance.discoveryUrl)
        
        self.urlRequest = URLRequest(url: url)
        self.urlSession = session
        self.correlationVector = correlationVector
    }
}
