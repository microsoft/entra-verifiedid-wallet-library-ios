/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationServiceExtensionError: Error 
{
    case unableToCastOpenIdForVCResponseToPresentationResponseContainer
}

/**
 * An extension of the VCServices.PresentationService class.
 */
extension PresentationService: OpenIdForVCResolver, OpenIdResponder 
{
    
    func validateRequest(data: Data) async throws -> any OpenIdRawRequest 
    {
        let request = try PresentationRequestDecoder().decode(data: data)
        return try await validate(request: request)
    }
    
    /// Fetches and validates the presentation request.
    func getRequest(url: String) async throws -> any OpenIdRawRequest 
    {
        return try await self.getRequest(usingUrl: url)
    }
    
    /// Sends the presentation response container and if successful, returns void,
    /// If unsuccessful, throws an error.
    func send(response: RawPresentationResponse, additionalHeaders: [String: String]?) async throws -> Void 
    {
        guard let presentationResponseContainer = response as? PresentationResponseContainer else 
        {
            throw PresentationServiceExtensionError.unableToCastOpenIdForVCResponseToPresentationResponseContainer
        }
        
        try await self.send(response: presentationResponseContainer, 
                            additionalHeaders: additionalHeaders)
    }
}
