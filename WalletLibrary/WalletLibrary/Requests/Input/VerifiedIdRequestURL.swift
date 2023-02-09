/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A URL used to initiate a Verified Id Request. For example, an Open Id reference url or a Contract url.
 */
public struct VerifiedIdRequestURL: VerifiedIdRequestInput, Equatable {
    
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
}
