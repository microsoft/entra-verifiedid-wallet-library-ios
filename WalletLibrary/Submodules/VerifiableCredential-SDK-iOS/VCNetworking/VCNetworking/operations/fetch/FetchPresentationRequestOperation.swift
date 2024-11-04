/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class FetchPresentationRequestOperation: InternalNetworkOperation {
    
    typealias ResponseBody = PresentationRequestToken
    
    private struct Constants {
        static let VersionNumberHeaderField = "prefer"
        static let VersionNumberHeaderValue = "JWT-interop-profile-0.0.1"
    }
    
    let decoder: PresentationRequestDecoder = PresentationRequestDecoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(withUrl urlStr: String,
         andCorrelationVector cv: VerifiedIdCorrelationHeader? = nil,
         session: URLSession) throws {
        
        guard let url = URL(unsafeString: urlStr) else 
        {
            throw VerifiedIdErrors.MalformedInput(message: "Invalid url: \(urlStr).").error
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlSession = session
        self.correlationVector = cv
        
        /// sets value in order to get a signed version of the contract
        if let value = urlSession.configuration.httpAdditionalHeaders?[Constants.VersionNumberHeaderField] {
            
            let newValue = "\(value);\(Constants.VersionNumberHeaderValue)"
            urlSession.configuration.httpAdditionalHeaders?[Constants.VersionNumberHeaderField] = newValue

        } else {
            self.urlRequest.addValue(Constants.VersionNumberHeaderValue,
                                     forHTTPHeaderField: Constants.VersionNumberHeaderField)
        }
    }
}
