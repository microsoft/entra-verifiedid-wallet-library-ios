/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Data that describes requested verified id formats.
 */
public struct CredentialFormat {
    
    /// The format of the verified Id requested such as jwt-vc.
    public let format: String
    
    /// The types of the requested verified Id.
    public let types: [String]
}
