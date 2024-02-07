/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// A protocol for `WalletLibraryNetworking` to be used to mock the class during testing.
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

/// Extend LibraryNetworking to allow for defaults in the method signatures.
extension LibraryNetworking
{
    func fetch<Operation: WalletLibraryFetchOperation>(url: URL,
                                                       _ type: Operation.Type,
                                                       additionalHeaders: [String: String]? = nil) async throws -> Operation.ResponseBody
    {
        return try await self.fetch(url: url, type, additionalHeaders: additionalHeaders)
    }
    
    func post<Operation: WalletLibraryPostOperation>(requestBody: Operation.RequestBody,
                                                     url: URL,
                                                     _ type: Operation.Type,
                                                     additionalHeaders: [String: String]? = nil) async throws -> Operation.ResponseBody
    {
        return try await self.post(requestBody: requestBody,
                                   url: url,
                                   type,
                                   additionalHeaders: additionalHeaders)
    }
}
