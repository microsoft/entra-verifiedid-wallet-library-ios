/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

enum MockLibraryNetworkingError: Error, Equatable
{
    case MockingNotSupportedForOperation(String)
    case ExpectedError
}

/**
 * A mock class for networking calls.
 */
struct MockLibraryNetworking: LibraryNetworking
{
    let getExpectedResponseBodies: (any InternalNetworkOperation.Type) throws -> Any
    
    let additionalHeaderSpy: (([String: String]?) -> Void)?
    
    init(getExpectedResponseBodies: @escaping (any InternalNetworkOperation.Type) throws -> Any,
         additionalHeaderSpy: (([String: String]?) -> Void)? = nil)
    {
        self.getExpectedResponseBodies = getExpectedResponseBodies
        self.additionalHeaderSpy = additionalHeaderSpy
    }
    
    /// Helper function to return MockLibraryNetworking that always throws.
    static func expectToThrow() -> MockLibraryNetworking
    {
        let alwaysThrow = { (_: Any) in throw MockLibraryNetworkingError.ExpectedError }
        return MockLibraryNetworking(getExpectedResponseBodies: alwaysThrow)
    }
    
    /// Helper function to create a MockLibraryNetworking that returns response body given based on type.
    static func create(expectedResults: [(Decodable, any InternalNetworkOperation.Type)],
                       additionalHeaderSpy: (([String: String]?) -> Void)? = nil) -> MockLibraryNetworking
    {
        let callback = { (input: any InternalNetworkOperation.Type) in
            
            for expected in expectedResults
            {
                if input == expected.1
                {
                    return expected.0
                }
            }
            
            throw MockLibraryNetworkingError.ExpectedError
        }
        
        return MockLibraryNetworking(getExpectedResponseBodies: callback,
                                     additionalHeaderSpy: additionalHeaderSpy)
    }
    
    func resetCorrelationHeader() { }
    
    func fetch<Operation: WalletLibraryFetchOperation>(url: URL,
                                                       _ type: Operation.Type,
                                                       additionalHeaders: [String : String]?) async throws -> Operation.ResponseBody
    {
        additionalHeaderSpy?(additionalHeaders)
        let expectedResponseBody = try getExpectedResponseBodies(type)
        
        if let responseBody = expectedResponseBody as? Operation.ResponseBody
        {
            return responseBody
        }
        else
        {
            throw MockLibraryNetworkingError.MockingNotSupportedForOperation(String(describing: type))
        }
    }
    
    func post<Operation: WalletLibraryPostOperation>(requestBody: Operation.RequestBody,
                                                     url: URL, _ type: Operation.Type, 
                                                     additionalHeaders: [String : String]?) async throws -> Operation.ResponseBody
    {
        let expectedResponseBody = try getExpectedResponseBodies(type)
        
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
