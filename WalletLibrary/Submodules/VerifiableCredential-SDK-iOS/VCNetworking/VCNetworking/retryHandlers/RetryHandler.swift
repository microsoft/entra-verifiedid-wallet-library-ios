/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol RetryHandler {
    func onRetry<ResponseBody>(closure: @escaping () async throws -> ResponseBody) async throws -> ResponseBody
}
