/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

public enum LinkedDomainResult: Error, Equatable {
    case linkedDomainMissing
    case linkedDomainUnverified(domainUrl: String)
    case linkedDomainVerified(domainUrl: String)
}
