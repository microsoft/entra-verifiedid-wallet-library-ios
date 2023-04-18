/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
@testable import VCNetworking

class UrlProtocolMock: URLProtocol {
    
    static func createMockResponse(httpResponse: Any, url: String, statusCode: Int) throws {
        var data: Data
        if let response = httpResponse as? String {
            data = response.data(using: .utf8)!
        } else {
            let encoder = JSONEncoder()
            data = try encoder.encode(httpResponse as! MockObject)
        }
        UrlProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: url)!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
    }
    
    // 1. Handler to test the request and return mock response.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // To check if this protocol can handle the given request.
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Here you return the canonical version of the request but most of the time you pass the orignal one.
        return request
    }
      
    override func startLoading() {
      guard let handler = UrlProtocolMock.requestHandler else {
        fatalError("Handler is unavailable.")
      }
        
      do {
        // 2. Call handler with received request and capture the tuple of response and data.
        let (response, data) = try handler(request)
        
        // 3. Send received response to the client.
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if let data = data {
          // 4. Send received data to the client.
          client?.urlProtocol(self, didLoad: data)
        }
        
        // 5. Notify request has been finished.
        client?.urlProtocolDidFinishLoading(self)
      } catch {
        // 6. Notify received error.
        client?.urlProtocol(self, didFailWithError: error)
      }
    }
    
    override func stopLoading() {
        // This is called if the request gets canceled or completed.
    }
}
