/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

class LinkedDomainService {
    
    private let wellKnownDocumentApiCalls: WellKnownConfigDocumentNetworking
    private let validator: DomainLinkageCredentialValidating
    
    convenience init(correlationVector: VerifiedIdCorrelationHeader? = nil,
                     urlSession: URLSession) {
        self.init(wellKnownDocumentApiCalls: WellKnownConfigDocumentNetworkCalls(correlationVector: correlationVector,
                                                                                 urlSession: urlSession),
                  domainLinkageValidator: DomainLinkageCredentialValidator())
    }
    
    init(wellKnownDocumentApiCalls: WellKnownConfigDocumentNetworking,
         domainLinkageValidator: DomainLinkageCredentialValidating) {
        self.wellKnownDocumentApiCalls = wellKnownDocumentApiCalls
        self.validator = domainLinkageValidator
    }
    
    func validateLinkedDomain(from identifierDocument: IdentifierDocument) async throws -> LinkedDomainResult {
        
        /// Try to resolve root of trust using root of trust resolver, fallback to old implementation if fails.
        if let rootOfTrustResolver = self.rootOfTrustResolver,
           let rootOfTrust = try? await rootOfTrustResolver.resolve(from: identifierDocument)
        {
            return self.getLinkedDomainResult(from: rootOfTrust)
        }
        
        guard let service = identifierDocument.service,
              let domainUrl = getLinkedDomainUrl(from: service) else {
            return .linkedDomainMissing
        }
        
        do {
            let wellKnownConfigDocument = try await wellKnownDocumentApiCalls.getDocument(fromUrl: domainUrl)
            return validateDomainLinkageCredentials(from: wellKnownConfigDocument,
                                                    using: identifierDocument,
                                                    andSourceUrl: domainUrl)
        } catch {
            return .linkedDomainUnverified(domainUrl: domainUrl)
        }
    }
    
    // TODO: Only looking for the well-known document in the first entry for now.
    private func getLinkedDomainUrl(from endpoints: [IdentifierDocumentServiceEndpointDescriptor]) -> String? {
        return endpoints.filter {
            $0.type == ServicesConstants.LINKED_DOMAINS_SERVICE_ENDPOINT_TYPE
        }.first?.serviceEndpoint.origins?.first
    }
    
    private func validateDomainLinkageCredentials(from wellKnownConfigDoc: WellKnownConfigDocument,
                                                  using identifierDocument: IdentifierDocument,
                                                  andSourceUrl url: String) -> LinkedDomainResult {
        
        var result = LinkedDomainResult.linkedDomainUnverified(domainUrl: url)
        wellKnownConfigDoc.linkedDids.forEach { credential in
            do {
                try validator.validate(credential: credential,
                                       usingDocument: identifierDocument,
                                       andSourceDomainUrl: url)
                result = .linkedDomainVerified(domainUrl: url)
            } catch { }
        }
        
        return result
    }
}
