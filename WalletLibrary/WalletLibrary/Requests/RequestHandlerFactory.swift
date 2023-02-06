/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors thrown in Request Handler Factory class.
 */
enum RequestHandlerFactoryError: Error {
    case UnsupportedResolver
}

/**
 * Request Handler Factory holds all objects that conform to RequestHandling protocol
 * and handles logic of returning the correct handler based on input.
 */
class RequestHandlerFactory {

    var requestHandlers: [RequestHandling]

    init(requestHandlers: [RequestHandling]) {
        self.requestHandlers = requestHandlers
    }

    /// Based on requestHandlers, return one that supports the resolver given.
    func makeHandler(from resolver: RequestResolving) throws -> RequestHandling {

        let handler = requestHandlers.filter {
            resolver.canResolve(using: $0)
        }.first
        
        guard let handler = handler else {
            throw RequestHandlerFactoryError.UnsupportedResolver
        }

        return handler
    }
}