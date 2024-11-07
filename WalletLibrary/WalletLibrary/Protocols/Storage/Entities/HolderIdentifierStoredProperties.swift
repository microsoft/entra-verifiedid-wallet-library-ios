/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A protocol defining properties for a stored holder identifier, representing the metadata needed to retrieve
 * or reference a holder identifier's information in persistent storage.
 */
protocol HolderIdentifierStoredProperties
{
    /// A unique identifier (UUID) for the private key that ties this holder to the key in key storage.
    var keyId: UUID? { get }

    /// The DID (Decentralized Identifier) method used, indicating the format or standard followed.
    var didMethod: String? { get }

    /// The cryptographic algorithm associated with this holder's key, such as "RSA" or "ECDSA".
    var algorithm: String? { get }

    /// A reference to the key to be used in cryptographic transactions.
    var keyReference: String? { get }
}
