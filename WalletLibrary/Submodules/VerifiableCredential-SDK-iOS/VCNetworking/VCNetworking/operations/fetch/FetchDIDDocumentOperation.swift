/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class FetchDIDDocumentOperation: InternalNetworkOperation {
    typealias ResponseBody = IdentifierDocument
    
    let decoder = DIDDocumentDecoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(withIdentifier identifier: String,
         andCorrelationVector correlationVector: VerifiedIdCorrelationHeader? = nil,
         session: URLSession) throws {
        
        guard var urlComponents = URLComponents(string: VCSDKConfiguration.sharedInstance.discoveryUrl) else {
            throw NetworkingError.invalidUrl(withUrl: VCSDKConfiguration.sharedInstance.discoveryUrl)
        }
        
        let pathSuffix = urlComponents.path.last == "/" ? identifier : "/" + identifier
        urlComponents.path = urlComponents.path + pathSuffix
        
        guard let url = urlComponents.url else {
            throw NetworkingError.invalidUrl(withUrl: urlComponents.string ?? VCSDKConfiguration.sharedInstance.discoveryUrl)
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlSession = session
        self.correlationVector = correlationVector
    }
}
