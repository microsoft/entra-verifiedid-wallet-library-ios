/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// A protocol defining the requirements for cryptographic operations that an identifier must support.
protocol CryptoRequirement
{
    /// Determines whether a given identifier supports the cryptographic requirements defined by the conforming type.
    ///
    /// - Parameter identifier: The `HolderIdentifier` to be evaluated.
    /// - Returns: `true` if the identifier meets the requirement; otherwise, `false`.
    func isSupported(identifier: HolderIdentifier) -> Bool
}
