/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors thrown in Request Handler Factory class.
 */
enum RequestHandlerFactoryError: Error 
{
    case UnsupportedRawRequest
}

/**
 * Request Handler Factory holds all objects that conform to RequestHandling protocol
 * and handles logic of returning the correct handler based on input.
 */
class RequestHandlerFactory 
{
    let requestHandlers: [any RequestHandling]

    init(requestHandlers: [any RequestHandling]) 
    {
        self.requestHandlers = requestHandlers
    }
    
    /// Return one of the request handlers that supports the raw request given.
    func getHandler(from rawRequest: Any) throws -> any RequestHandling
    {
        for handler in requestHandlers 
        {
            if handler.canHandle(rawRequest: rawRequest)
            {
                return handler
            }
        }

        throw RequestHandlerFactoryError.UnsupportedRawRequest
    }
}
