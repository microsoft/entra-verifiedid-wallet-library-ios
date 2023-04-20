/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public struct Microsoft2020IdentifierBackup : Codable {
    
    private struct Constants {
        /// For compatability with the Android backup data model:
        static let OnTheWireMainIdentifier = "did.main.identifier"
    }
    
    private var entries = [RawIdentity]()
    
    public init() { }

    public init(from decoder:Decoder) throws
    {
        let container = try decoder.singleValueContainer()
        self.entries = try container.decode([RawIdentity].self)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(self.entries)
    }

    public mutating func setMain(_ identifier:Identifier) throws {
        
        // Try and convert
        var entry = try RawIdentity(identifier: identifier)
        entry.name = Constants.OnTheWireMainIdentifier

        // Remove any incidence in the array using the same identifier
        entries.removeAll(where: {$0.name == entry.name})
        
        // Insert the new master identity at the head of the array
        entries.insert(entry, at: 0)
    }
    
    public mutating func add(_ identifier:Identifier) throws {
        
        let entry = try RawIdentity(identifier: identifier)
        entries.append(entry)
    }

    public func all() throws -> [Identifier]
    {
        // Look for the main identifier
        var main: Identifier? = nil
        if var found = entries.first(where: {$0.name == Constants.OnTheWireMainIdentifier}) {
            found.name = AliasComputer().compute(forId: VCEntitiesConstants.MASTER_ID,
                                                 andRelyingParty: VCEntitiesConstants.MASTER_ID)
            do {
                main = try found.asIdentifier()
            }
            catch (let error) {
                VCSDKLog.sharedInstance.logError(message: "Failed to read \(found) as the main identifier with error \(error)")
                throw error
            }
        }

        // Set the main identifier, if any, as the first returned
        var identifiers = [Identifier]()
        if let alpha = main {
            identifiers.append(alpha)
        }
        try entries.forEach { entry in
            // Skip the main identifier (if we encounter it again)
            if entry.name == Constants.OnTheWireMainIdentifier {
                return
            }
            try identifiers.append(entry.asIdentifier())
        }
        return identifiers
    }
}
