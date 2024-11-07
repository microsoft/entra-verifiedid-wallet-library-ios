/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

protocol EllipticCurvePublicKey: PublicKey
{
    var x: Data { get }

    var y: Data { get }

    var curve: String { get }

    var keyType: String { get }
}

extension EllipticCurvePublicKey
{
    var keyType: String
    {
        return "EC"
    }
}
