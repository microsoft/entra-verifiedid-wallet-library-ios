/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class OpenIdJWTV1Processor: RequestProcessor {
    
    let requestParams: AdditionalRequestParams = OpenIdRequestParams()
    
    let configuration: VerifiedIdClientConfiguration
    
    init(configuration: VerifiedIdClientConfiguration) {
        self.configuration = configuration
    }
    
    func canProcess(rawRequest: RawRequest) -> Bool {
        
        if rawRequest is OpenIdURLRequest {
            return true
        }
        
        return false
    }
    
    func process(rawRequest: RawRequest) async throws -> any VerifiedIdRequest {
        
        guard let openIdRequest = rawRequest as? OpenIdURLRequest else {
            throw VerifiedIdClientError.TODO(message: "not an open id url request")
        }
        
        print(openIdRequest.presentationRequest)
        let mapper = Mapper()
        
        let requirement = try mapper.map(openIdRequest.presentationRequest.content.claims!.vpToken!.presentationDefinition!)
        
        return VerifiedIdIssuanceRequest(style: MockRequesterStyle(requester: openIdRequest.presentationRequest.content.registration?.clientName ?? "requester"),
                                         requirement: requirement,
                                         rootOfTrust: RootOfTrust(verified: true, source: "test source"),
                                         configuration: configuration)
    }
}
