/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Supported curve algorithms used for signing/verification
public enum SupportedCurve: String {
    case ED25519 = "ED25519"
    case Secp256k1 = "SECP256K1"
}
