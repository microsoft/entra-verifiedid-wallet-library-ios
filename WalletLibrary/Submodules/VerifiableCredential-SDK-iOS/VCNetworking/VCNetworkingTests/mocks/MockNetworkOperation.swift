/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import VCEntities
@testable import VCNetworking

final class MockNetworkOperation: InternalNetworkOperation {
    
    typealias ResponseBody = MockDecoder.ResponseBody
    typealias Decoder = MockDecoder
    
    let decoder: MockDecoder = MockDecoder()
    let successHandler: SuccessHandler = SimpleSuccessHandler()
    let failureHandler: FailureHandler = SimpleFailureHandler()
    let retryHandler: RetryHandler = NoRetry()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: CorrelationHeader? = nil
    
    let mockUrl = "mockurl.com"
    
    init () {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [UrlProtocolMock.self]
        self.urlSession = URLSession.init(configuration: configuration)
        self.urlRequest = URLRequest(url: URL(string: mockUrl)!)
    }
}
