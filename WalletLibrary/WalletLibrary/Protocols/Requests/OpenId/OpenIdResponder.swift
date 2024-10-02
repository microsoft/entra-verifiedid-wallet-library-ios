/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 * Protocol is used as a wrapper to wrap the VC SDK send presentation response method.
 */
protocol OpenIdResponder {
    /// Sends the presentation response and if successful, returns void,
    /// If unsuccessful, throws an error.
    func send(response: RawPresentationResponse) async throws -> Void
}

class TestOpenIdResponder: OpenIdResponder
{
    private let identifier: VerifiedIdIdentifier
    
    private let configuration: LibraryConfiguration
    
    private let formatter: PresentationResponseFormatter
    
    init(identifier: VerifiedIdIdentifier,
         configuration: LibraryConfiguration,
         formatter: PresentationResponseFormatter)
    {
        self.identifier = identifier
        self.configuration = configuration
        self.formatter = formatter
    }
    
    func send(response: RawPresentationResponse) async throws -> Void
    {
        guard let presentationResponseContainer = response as? PresentationResponseContainer else
        {
            throw PresentationServiceExtensionError.unableToCastOpenIdForVCResponseToPresentationResponseContainer
        }
        
        let audienceURL = try URL.getRequiredProperty(property: URL(string: presentationResponseContainer.audienceUrl),
                                                      propertyName: "audience_url")
        
        let formattedResponse = try formatter.format(response: presentationResponseContainer,
                                                     usingIdentifier: identifier)
        
        let _ = try await configuration.networking.post(requestBody: formattedResponse,
                                                        url: audienceURL,
                                                        PostPresentationResponseOperation.self,
                                                        additionalHeaders: nil)
        
    }
}
