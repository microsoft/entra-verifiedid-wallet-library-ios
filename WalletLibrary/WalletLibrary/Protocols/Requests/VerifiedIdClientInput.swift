/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Input to initiate a Verified Id Flow.
 */
public protocol VerifiedIdClientInput {
    func resolve(with configuration: VerifiedIdClientConfiguration) -> any VerifiedIdRequest
}
