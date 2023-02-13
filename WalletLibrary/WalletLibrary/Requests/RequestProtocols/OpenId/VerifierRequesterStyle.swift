/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Requester Style that is specific to the verifier.
 */
public protocol VerifierStyle: RequesterStyle {
    var name: String { get }
}

struct OpenIdVerifierStyle: VerifierStyle, Equatable {
    let name: String
}

public protocol IssuerStyle: RequesterStyle {
    var name: String { get }
}

struct MSIssuerStyle: IssuerStyle, Equatable {
    let name: String
}
