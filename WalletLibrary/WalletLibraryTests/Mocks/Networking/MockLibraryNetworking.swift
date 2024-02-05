/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

enum MockLibraryNetworkingError: Error
{
    case MockingNotSupportedForOperation(String)
}

/**
 *
 */
struct MockLibraryNetworking: LibraryNetworking
{
    let getExpectedResponseBodies: ((Any) -> Any)
    
    init(getExpectedResponseBodies: @escaping ((Any) -> Any))
    {
        self.getExpectedResponseBodies = getExpectedResponseBodies
    }
    
    func resetCorrelationHeader() { }
    
    func fetch<Operation: WalletLibraryFetchOperation>(url: URL,
                                                       _ type: Operation.Type,
                                                       additionalHeaders: [String : String]?) async throws -> Operation.ResponseBody
    {
        let expectedResponseBody = getExpectedResponseBodies(type)
        if let responseBody = expectedResponseBody as? Operation.ResponseBody
        {
            return responseBody
        }
        else
        {
            throw MockLibraryNetworkingError.MockingNotSupportedForOperation(String(describing: type))
        }
    }
}
