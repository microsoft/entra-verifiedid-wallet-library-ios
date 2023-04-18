/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct Constants {
    static let POST = "POST"
    static let FORM_URLENCODED = "application/x-www-form-urlencoded"
    static let PLAIN_TEXT = "text/plain"
    static let JSON = "application/json"
    static let CONTENT_TYPE = "Content-Type"
    
    // Header values for signed contracts
    static let SIGNED_CONTRACT_HEADER_FIELD = "x-ms-sign-contract"
    static let SIGNED_CONTRACT_HEADER_VALUE = "true"
    
    static let WELL_KNOWN_SUBDOMAIN = "/.well-known/did-configuration.json"
    
    // Header value for tracing user agent in network calls.
    static let USER_AGENT = "User-Agent"
}
