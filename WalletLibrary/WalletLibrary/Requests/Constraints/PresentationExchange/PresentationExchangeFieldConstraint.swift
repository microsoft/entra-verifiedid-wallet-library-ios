/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationExchangeFieldConstraintsError: String, Error
{
    case NoPathsFoundOnPresentationExchangeField = "No paths found on presentation exchange field."
    case UnableToCastVerifiedIdToVerifiableCredential = "Unable to case Verified Id to Verifiable Credential."
    case UnableToEncodeVCAsJSON = "Unable to encode Verifiable Credential as JSON."
    case VerifiedIdDoesNotMatchConstraints = "Verified Id does not match constraints."
}

/// Presentation Exchange Pattern used to match an input string with pattern.
struct PresentationExchangeFieldConstraint: VerifiedIdConstraint {
    
    private let field: PresentationExchangeField
    
    private let paths: [String]
    
    init(field: PresentationExchangeField) throws {
        
        guard let paths = field.path else
        {
            let innerError = PresentationExchangeFieldConstraintsError.NoPathsFoundOnPresentationExchangeField
            throw VerifiedIdErrors.MalformedInput(error: innerError).error
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
        
        guard let verifiableCredential = verifiedId as? VCVerifiedId else
        {
            let innerError = PresentationExchangeFieldConstraintsError.UnableToCastVerifiedIdToVerifiableCredential
            throw VerifiedIdErrors.MalformedInput(error: innerError).error
        }
        
        let encodedContent = try JSONEncoder().encode(verifiableCredential.raw.content)
            
            guard let vc = try JSONSerialization.jsonObject(with: encodedContent) as? [String: Any] else
            {
                let innerError = PresentationExchangeFieldConstraintsError.UnableToEncodeVCAsJSON
                throw VerifiedIdErrors.MalformedInput(error: innerError).error
            }
            
            for path in paths
            {
                let value = vc.getValue(with: path)
                if let expectedValue = value as? String
                {
                    if doesFilterMatch(expectedValue: expectedValue)
                    {
                        return
                    }
                }
            }
        
        let innerError = PresentationExchangeFieldConstraintsError.VerifiedIdDoesNotMatchConstraints
        throw VerifiedIdErrors.MalformedInput(error: innerError).error
    }
    
    private func doesFilterMatch(expectedValue: String) -> Bool
    {
        guard let patternStr = field.filter?.pattern?.pattern,
              let pattern = PresentationExchangePattern(from: patternStr) else
        {
            return false
        }
        
        return pattern.matches(in: expectedValue)
    }
}
