/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public enum NetworkingError: Error, Equatable {
    case badRequest(withBody: String, statusCode: Int)
    case forbidden(withBody: String, statusCode: Int)
    case invalidUrl(withUrl: String?)
    case notFound(withBody: String, statusCode: Int)
    case serverError(withBody: String, statusCode: Int)
    case unauthorized(withBody: String, statusCode: Int)
    case unknownNetworkingError(withBody: String, statusCode: Int)
    case unableToParseString
    case unableToParseData
}
