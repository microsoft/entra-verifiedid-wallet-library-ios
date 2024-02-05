/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol LibraryNetworking
{
    func resetCorrelationHeader()
    
    func fetch<Operation: WalletLibraryFetchOperation>(url: URL,
                                                       _ type: Operation.Type,
                                                       additionalHeaders: [String: String]?) async throws -> Operation.ResponseBody
    
    func post<Operation: WalletLibraryPostOperation>(requestBody: Operation.RequestBody,
                                                     url: URL,
                                                     _ type: Operation.Type,
                                                     additionalHeaders: [String: String]?) async throws -> Operation.ResponseBody
}
