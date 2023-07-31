/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationExchangeFieldConstraintError: String, Error
{
    case NoPathsFoundOnPresentationExchangeField = "No paths found on presentation exchange field."
    case UnableToCastVerifiedIdToVerifiableCredential = "Unable to case Verified Id to Verifiable Credential."
    case VerifiedIdDoesNotMatchConstraints = "Verified Id does not match constraints."
}

/**
 * A Verifiable Credential specific constraint for the Presentation Exchange Field specifications.
 */
struct PresentationExchangeFieldConstraint: VerifiedIdConstraint {
    
    private let field: PresentationExchangeField
    
    private let paths: [String]
    
    init(field: PresentationExchangeField) throws {
        
        guard let paths = field.path,
              !paths.isEmpty else {

            throw PresentationExchangeFieldConstraintError.NoPathsFoundOnPresentationExchangeField
        }
        
        self.field = field
        self.paths = paths
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
        
        guard let verifiableCredential = verifiedId as? VCVerifiedId,
              let encodedContent = try? JSONEncoder().encode(verifiableCredential.raw.content),
              let vc = try JSONSerialization.jsonObject(with: encodedContent) as? [String: Any] else {

            throw PresentationExchangeFieldConstraintError.UnableToCastVerifiedIdToVerifiableCredential
        }
            
        for path in paths {
            
            let value = vc.getValue(with: path)
            if let expectedValue = value as? String {
                
                if doesFilterMatch(expectedValue: expectedValue) {
                    return
                }
            }
        }
        
        throw PresentationExchangeFieldConstraintError.VerifiedIdDoesNotMatchConstraints
    }
    
    private func doesFilterMatch(expectedValue: String) -> Bool
    {
        guard let patternStr = field.filter?.pattern?.pattern,
              let pattern = PresentationExchangePattern(from: patternStr) else {
            return false
        }
        
        return pattern.matches(in: expectedValue)
    }
}
