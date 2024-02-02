/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The constraints for issuance and display information of a credential,
 */
struct OpenID4VCIRequestNetworkOperation: WalletLibraryNetworkOperation
{
    typealias ResponseBody = Data
    
    typealias Decoder = TestDecoder
    
    var decoder: TestDecoder
    
    var urlSession: URLSession
    
    var urlRequest: URLRequest
    
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(urlSession: URLSession,
         urlRequest: URLRequest,
         correlationVector: VerifiedIdCorrelationHeader?)
    {
        self.decoder = TestDecoder()
        self.urlSession = urlSession
        self.urlRequest = urlRequest
        self.correlationVector = correlationVector
    }
}

struct TestDecoder: Decoding
{
    func decode(data: Data) throws -> Data {
        return Data()
    }
    
    typealias ResponseBody = Data
    
    
}

protocol WalletLibraryNetworkOperation: InternalNetworkOperation
{
    init(urlSession: URLSession, 
         urlRequest: URLRequest,
         correlationVector: VerifiedIdCorrelationHeader?)
}
