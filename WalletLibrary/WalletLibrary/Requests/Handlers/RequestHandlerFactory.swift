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

    let requestHandlers: [any RequestHandling]

    init(requestHandlers: [any RequestHandling]) {
        self.requestHandlers = requestHandlers
    }

    /// Return one of the request handlers that supports the resolver given.
    func getHandler(from resolver: some RequestResolving) throws -> any RequestHandling {

        let handler = requestHandlers.filter {
            resolver.canResolve(using: $0)
        }.first
        
        guard let handler = handler else {
            throw RequestHandlerFactoryError.UnsupportedResolver
        }

        return handler
    }
}
