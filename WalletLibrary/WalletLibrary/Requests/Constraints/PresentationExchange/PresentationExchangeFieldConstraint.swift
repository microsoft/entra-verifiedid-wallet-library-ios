/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationExchangeFieldConstraintError: Error, CustomStringConvertible
{
    case NoPathsFoundOnPresentationExchangeField
    case UnableToCastVerifiedIdToVerifiableCredential
    case VerifiedIdDoesNotMatchConstraints
    case InvalidPatternOnThePresentationExchangeField
    
    var description: String {
        switch self {
        case .NoPathsFoundOnPresentationExchangeField:
            return "No paths found on presentation exchange field."
        case .UnableToCastVerifiedIdToVerifiableCredential:
            return "Unable to case Verified Id to Verifiable Credential."
        case .VerifiedIdDoesNotMatchConstraints:
            return "Verified Id does not match constraints."
        case .InvalidPatternOnThePresentationExchangeField:
            return "Invalid Pattern on the presentation exchange field."
        }
    }
}

/**
 * A Verifiable Credential specific constraint for the Presentation Exchange Field specifications.
 */
struct PresentationExchangeFieldConstraint: VerifiedIdConstraint {
    
    private let field: PresentationExchangeField
    
    private let paths: [String]
    
    private let pattern: PresentationExchangePattern
    
    init(field: PresentationExchangeField) throws {
        
        guard let paths = field.path,
              !paths.isEmpty else {
            throw PresentationExchangeFieldConstraintError.NoPathsFoundOnPresentationExchangeField
        }
        
        guard let patternStr = field.filter?.pattern?.pattern,
              let pattern = PresentationExchangePattern(from: patternStr) else {
            throw PresentationExchangeFieldConstraintError.InvalidPatternOnThePresentationExchangeField
        }
        
        self.field = field
        self.paths = paths
        self.pattern = pattern
    }
    
    func doesMatch(verifiedId: VerifiedId) -> Bool {
        do {
            try matches(verifiedId: verifiedId)
            return true
        } catch {
            return false
        }
    }
    
    func matches(verifiedId: VerifiedId) throws {
        
        guard let verifiableCredential = verifiedId as? InternalVerifiedId,
              let encodedContent = try? JSONEncoder().encode(verifiableCredential.raw.content),
              let vc = try JSONSerialization.jsonObject(with: encodedContent) as? [String: Any] else {

            throw PresentationExchangeFieldConstraintError.UnableToCastVerifiedIdToVerifiableCredential
        }
            
        for path in paths {
            
            let value = vc.getValue(with: path)
            if let expectedValue = value as? String {
                
                if pattern.matches(in: expectedValue) {
                    return
                }
            }
        }
        
        throw PresentationExchangeFieldConstraintError.VerifiedIdDoesNotMatchConstraints
    }
}
