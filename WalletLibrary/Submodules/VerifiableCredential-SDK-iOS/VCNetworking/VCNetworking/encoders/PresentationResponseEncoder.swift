/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

#if canImport(VCToken)
    import VCToken
#endif

enum PresentationResponseEncoderError: Error {
    case noVerifiablePresentationInResponse
    case unableToSerializeResponse
}

struct PresentationResponseEncoder: Encoding {
    
    private struct Constants
    {
        static let idToken = "id_token"
        static let vpToken = "vp_token"
        static let state = "state"
    }
    
    func encode(value: PresentationResponse) throws -> Data {
        
        let idTokenParam = "\(Constants.idToken)=\(try value.idToken.serialize())"
        
        guard let vpToken = value.vpToken else {
            throw PresentationResponseEncoderError.noVerifiablePresentationInResponse
        }
        
        let vpTokenParam = "\(Constants.vpToken)=\(try vpToken.serialize())"
        
        var responseBody = "\(idTokenParam)&\(vpTokenParam)"
        
        if let state = value.state?.stringByAddingPercentEncodingForRFC3986() {
            let stateParam = "\(Constants.state)=\(state)"
            responseBody.append(contentsOf: "&\(stateParam)")
        }
        
        guard let response = responseBody.data(using: .utf8) else
        {
            throw PresentationResponseEncoderError.unableToSerializeResponse
        }
        
        return response
    }
}
