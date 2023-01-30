/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Root of Trust such as Linked Domain Verified for the request.
 */
public struct RootOfTrust {
    
    /// Whether root of trust is verified or not (for example, if the linked domain check succeeded.
    public let verified: Bool
    
    /// The source of the root of trust (could be the well-known endpoint url or a hub perhaps).
    public let source: String?
    
}
