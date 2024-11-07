/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * A protocol representing an elliptic curve public key, conforming to the `PublicKey` protocol.
 * This protocol defines the common properties required for public keys that use elliptic curve cryptography.
 */
protocol EllipticCurvePublicKey: PublicKey
{
    /// The x-coordinate of the elliptic curve public key.
    /// This is typically represented as a `Data` object and contains the x-value of the key's point on the curve.
    var x: Data { get }

    /// The y-coordinate of the elliptic curve public key.
    /// This is typically represented as a `Data` object and contains the y-value of the key's point on the curve.
    var y: Data { get }

    /// The name of the elliptic curve used by the key.
    /// For example, this could be "P-256" for keys used in the ES256 (Elliptic Curve Digital Signature Algorithm) standard.
    var curve: String { get }

    
    /// The type of the key, typically represented as "EC" for elliptic curve keys.
    /// This defines the key's classification according to JWK (JSON Web Key) standards.
    var keyType: String { get }
}

extension EllipticCurvePublicKey
{
    var keyType: String
    {
        return "EC"
    }
}
