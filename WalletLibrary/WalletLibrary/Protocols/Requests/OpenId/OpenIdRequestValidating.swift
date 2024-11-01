/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Protocol is used to validate an open id presentaiton request.
 */
protocol OpenIdRequestValidating 
{
    /// Validates the serialized presentation request.
    func validateRequest(data: Data) async throws -> any OpenIdRawRequest
}
