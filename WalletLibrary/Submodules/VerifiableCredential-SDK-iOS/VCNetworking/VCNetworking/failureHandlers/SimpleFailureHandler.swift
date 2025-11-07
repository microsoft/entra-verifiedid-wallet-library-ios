/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation

class SimpleFailureHandler: FailureHandler 
{
    private let sdkLog: VCSDKLog
    
    private let correlationVector: VerifiedIdCorrelationHeader?
    
    init(sdkLog: VCSDKLog, correlationVector: VerifiedIdCorrelationHeader? = nil)
    {
        self.sdkLog = sdkLog
        self.correlationVector = correlationVector
    }
    
    func onFailure(data: Data, response: HTTPURLResponse) throws -> VerifiedIdError 
    {
        var cvValue = ""
        if let cvName = correlationVector?.name
        {
            cvValue = response.allHeaderFields[cvName] as? String ?? ""
        }
        
        let headers = Dictionary(uniqueKeysWithValues: response.allHeaderFields.compactMap {
            key, value in
            if let stringValue = value as? String
            {
                return Dictionary.Element(key: key.description, value: stringValue)
            }
            else if let losslessStringValue = value as? LosslessStringConvertible
            {
                return Dictionary.Element(key: key.description, value: losslessStringValue.description)
            }
            else
            {
                return nil
            }
        })

        guard let responseBody = String(data: data, encoding: .utf8) else
        {
            throw VerifiedIdErrors.NetworkingError(message: "Unable to parse response body.",
                                                   correlationId: cvValue,
                                                   statusCode: response.statusCode,
                                                   headers: headers).error
        }
        
        let networkingError = VerifiedIdErrors.NetworkingError(message: responseBody,
                                                               correlationId: cvValue,
                                                               statusCode: response.statusCode,
                                                               headers: headers).error
        
        self.logNetworkingError(error: networkingError)
        return networkingError
    }
    
    private func logNetworkingError(error: VerifiedIdError)
    {
        sdkLog.logError(message: """
            Networking Error: \(String(describing: error))
            """)
    }
}
