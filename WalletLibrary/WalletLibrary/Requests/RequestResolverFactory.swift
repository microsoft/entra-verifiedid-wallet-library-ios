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
    
    private let resolvers: [RequestResolving]
    
    init(resolvers: [RequestResolving]) {
        self.resolvers = resolvers
    }
    
    func makeResolver(from input: VerifiedIdClientInput) throws -> RequestResolving {
        
        let resolver = resolvers.filter {
            $0.canResolve(input: input)
        }.first
        
        guard let resolver = resolver else {
            throw RequestResolverFactoryError.UnsupportedInput
        }
        
        return resolver
    }
}

