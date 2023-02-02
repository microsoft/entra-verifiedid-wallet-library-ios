/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Parameters used for an Issuance during Presentation flow
 * to define information needed for the issuance of the requested Verified Id.
 */
public struct IssuanceOptions: Equatable {
    
    /// A list of issuers that are accepted.
    public let acceptedIssuers: [String]
    
    /// Information such as a contract URL to describe where to get contract.
    public let credentialIssuerMetadata: [String]
}


