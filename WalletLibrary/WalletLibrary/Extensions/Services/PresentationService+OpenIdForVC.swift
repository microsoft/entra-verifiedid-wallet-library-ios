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
extension OpenIdPresentationRequestValidator: OpenIdRequestValidating
{
    func validateRequest(data: Data) async throws -> any OpenIdRawRequest 
    {
        let request = try PresentationRequestDecoder().decode(data: data)
        return try await validate(request: request)
    }
}
