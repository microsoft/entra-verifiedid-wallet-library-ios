/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The look and feel of the requester who has initiated the request.
 */
public protocol RequesterStyle {
    /// The name of the requester.
    var name: String { get }
}

