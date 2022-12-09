/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 *
 */
protocol RequestHandling {
    
    func handle(requestUri: URL) async throws -> Request
    
}
