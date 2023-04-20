/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public protocol ResponseContaining {
    var audienceUrl: String { get }
    var audienceDid: String { get }
    var requestVCMap: RequestedVerifiableCredentialMap { get set }
}
