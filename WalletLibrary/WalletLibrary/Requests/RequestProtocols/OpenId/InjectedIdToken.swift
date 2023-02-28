/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An object that represents an id token that is injected from a presentation request into an issuance request.
 */
struct InjectedIdToken {
    let rawToken: String
    
    let pin: PinRequirement?
}
