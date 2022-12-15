/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/// Protocol that handles getting vc sdk presentation requests and sending vc sdk presentation responses.
protocol PresentationServiceable {
    
    /// Fetches and validates the presentation request.
    func getRequest(url: String) async throws -> VCEntities.PresentationRequest
    
    /// Sends the presentation response container and if successful, returns void,
    /// If unsuccessful, throws an error.
    func send(response: PresentationResponseContainer) async throws -> Void
}
