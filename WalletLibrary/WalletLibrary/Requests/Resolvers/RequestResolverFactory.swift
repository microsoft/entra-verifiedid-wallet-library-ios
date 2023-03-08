/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors thrown in Request Resolver Factory class.
 */
enum RequestResolverFactoryError: Error {
    case UnsupportedInput
}

/**
 * Request Resolver Factory holds all objects that conform to RequestResolving protocol
 * and handles logic of returning the correct resolver based on input.
 */
class RequestResolverFactory {
    
    let resolvers: [any RequestResolving]
    
    init(resolvers: [any RequestResolving]) {
        self.resolvers = resolvers
    }
    
    /// Return one of the resolvers that supports the input given.
    func getResolver(from input: VerifiedIdRequestInput) throws -> any RequestResolving {
        
        let resolver = resolvers.filter {
            $0.canResolve(input: input)
        }.first
        
        guard let resolver = resolver else {
            throw RequestResolverFactoryError.UnsupportedInput
        }
        
        return resolver
    }
}

