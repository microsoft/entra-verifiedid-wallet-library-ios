/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// A factory class responsible for managing and selecting appropriate identifiers based on cryptographic requirements.
class IdentifierFactory
{
    /// A list of all available identifiers, arranged in priority order, with FIPS-compliant identifiers listed first.
    let identifiers: [HolderIdentifier]
    
    /// Initializes a new `IdentifierFactory` with a prioritized list of identifiers.
    ///
    /// - Parameter identifiers: An array of `HolderIdentifier` instances, ordered by priority.
    init(identifiers: [HolderIdentifier])
    {
        self.identifiers = identifiers
    }
    
    /// Retrieves an identifier that meets the specified cryptographic requirements.
    ///
    /// - Parameter cryptoRequirement: The cryptographic requirement to be met. If `nil`, pick the first one on the list.
    /// - Returns: A `HolderIdentifier` that supports the given requirement, or `nil` if none is found.
    func getIdentifier(for cryptoRequirement: CryptoRequirement? = nil) throws -> HolderIdentifier
    {
        if let cryptoRequirement = cryptoRequirement,
           let identifier = identifiers.filter({ cryptoRequirement.isSupported(identifier: $0) }).first
        {
            return identifier
        }
        else if let identifier = identifiers.first
        {
            return identifier
        }
        else
        {
            throw VerifiedIdError(message: "No Holder Identifier matches requirements.",
                                  code: "no_holder_identifier_found.")
        }
    }
}
