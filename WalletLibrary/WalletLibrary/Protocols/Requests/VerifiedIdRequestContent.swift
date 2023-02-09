/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents in a Verified Id Request.
 * This protocol is used to map protocol specific requests to common request object.
 */
struct VerifiedIdRequestContent {
    
    let style: RequesterStyle
    
    let requirement: Requirement
    
    let rootOfTrust: RootOfTrust
}
