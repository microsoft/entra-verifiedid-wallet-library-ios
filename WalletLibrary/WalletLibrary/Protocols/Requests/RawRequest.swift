/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw Request that has been resolved.
 */
protocol RawRequest {
    
    /// The raw value of the request.
    var raw: Data { get }
}


