/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Utility class to assist in creating Additional Headers for network requests.
class AdditionalHeaders
{
    private var headers: [String: String] = [:]
    
    // If the header already exists, append the value to existing value.
    func addHeader(fieldName: String, value: String)
    {
        if let headerValue = headers[fieldName]
        {
            headers[fieldName] = "\(headerValue),\(value)"
        }
        else
        {
            headers[fieldName] = value
        }
    }
    
    func getHeaders() -> [String: String]
    {
        return headers
    }
}
