/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Request Handling Protocol
 */
protocol RequestHandling {
    
    /// Handle a request using the request uri and return an object that conforms to the Request protocol.
    func handle(requestUri: URL) async throws -> Request
    
}
