/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of serializing a Verified ID
 */
public protocol VerifiedIdSerializing<SerializedFormat> {
    associatedtype SerializedFormat
    
    /**
     * Serialize the given verifiedID into the SerializedFormat
     */
    func serialize(verifiedId: VerifiedId) throws -> SerializedFormat
}
