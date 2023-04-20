/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import PromiseKit

struct MetricConstants {
    static let Name = "eventName"
    static let Duration = "duration_ms"
}

public func logTime<R>(name: String,
                    _ block: @escaping () -> Promise<R>) -> Promise<R> {
    
    let startTimeInSeconds = CFAbsoluteTimeGetCurrent()
    let result = block().get { body in
        
        let elapsedTimeInMilliseconds = (CFAbsoluteTimeGetCurrent() - startTimeInSeconds) * 1000
        
        VCSDKLog.sharedInstance.event(name: "DIDPerformanceMetrics",
                                      properties: [MetricConstants.Name: name],
                                      measurements: [MetricConstants.Duration: NSNumber(value: elapsedTimeInMilliseconds)])
    }
    
    return result
}

public func logNetworkTime(name: String,
                    correlationVector: CorrelationHeader? = nil,
                    _ block: @escaping () -> Promise<(data: Data, response: URLResponse)>) -> Promise<(data: Data, response: URLResponse)> {
    
    let startTimeInSeconds = CFAbsoluteTimeGetCurrent()
    let result = block().get { body in
        
        let elapsedTimeInMilliseconds = (CFAbsoluteTimeGetCurrent() - startTimeInSeconds) * 1000
        
        var properties = [
            MetricConstants.Name: name,
            "CV_request": correlationVector?.value ?? ""
        ]
        
        if let httpResponse = body.response as? HTTPURLResponse {
            properties["isSuccessful"] = String(describing: httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
            properties["CV_response"] = httpResponse.allHeaderFields[correlationVector?.name] as? String ?? ""
            properties["code"] = String(describing: httpResponse.statusCode)
        }
        
        let measurements = [MetricConstants.Duration: NSNumber(value: elapsedTimeInMilliseconds)]
        
        VCSDKLog.sharedInstance.event(name: "DIDNetworkMetrics", properties: properties, measurements: measurements)
    }

    return result
}
