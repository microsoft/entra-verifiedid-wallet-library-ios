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
        // Throw error if no identifiers found in factory.
        guard !identifiers.isEmpty,
              let firstIdentifier = identifiers.first else
        {
            throw VerifiedIdError(message: "No Holder Identifiers found.",
                                  code: "no_holder_identifier_found.")
        }
        
        // Return first identifier in list if no Crypto Requirements.
        guard let cryptoRequirement = cryptoRequirement else
        {
            return firstIdentifier
        }
                
        // Finally, filter through identifiers to find first matching identifier that supports requirement.
        // Else, return error.
        if let identifier = identifiers.filter({ cryptoRequirement.isSupported(identifier: $0) }).first
        {
            return identifier
        }
        else
        {
            throw VerifiedIdError(message: "No Holder Identifier matches requirements.",
                                  code: "no_holder_identifier_match_found.")
        }
    }
}
