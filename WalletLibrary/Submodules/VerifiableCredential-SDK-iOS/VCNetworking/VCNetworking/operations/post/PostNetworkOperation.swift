/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

internal protocol InternalPostNetworkOperation: PostNetworkOperation & InternalPostOperation {}

protocol PostNetworkOperation: NetworkOperation {
    associatedtype RequestBody
}

protocol InternalPostOperation: InternalNetworkOperation {
    associatedtype Encoder: Encoding
    associatedtype RequestBody where RequestBody == Encoder.RequestBody
}
