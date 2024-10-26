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
        
        guard var urlComponents = URLComponents(string: VCSDKConfiguration.sharedInstance.discoveryUrl) else 
        {
            throw VerifiedIdErrors.MalformedInput(message: "Invalid url: \(VCSDKConfiguration.sharedInstance.discoveryUrl).").error
        }
        
        let pathSuffix = urlComponents.path.last == "/" ? identifier : "/" + identifier
        urlComponents.path = urlComponents.path + pathSuffix
        
        guard let url = urlComponents.url else 
        {
            throw VerifiedIdErrors.MalformedInput(message: "Invalid url: \(urlComponents.string ?? "").").error
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlSession = session
        self.correlationVector = correlationVector
    }
}
