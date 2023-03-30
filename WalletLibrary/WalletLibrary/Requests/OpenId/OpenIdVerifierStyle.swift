/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Requester Style that is Open Id specific.
 */
public struct OpenIdVerifierStyle: RequesterStyle, Equatable {
    /// The name of the verifier.
    public let name: String
    
    /// The logo of the verifier.
    public let logo: VerifiedIdLogo?
}
