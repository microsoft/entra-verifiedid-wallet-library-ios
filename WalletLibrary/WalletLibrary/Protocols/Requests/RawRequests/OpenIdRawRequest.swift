/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Representation of a Raw Open Id Request.
protocol OpenIdRawRequest {
    
    var raw: Data? { get }
}
