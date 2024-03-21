/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Basic Claims within a JWS token.
protocol Claims: Codable {
    
    var iat: Int? { get }
    var exp: Int? { get }
    var nbf: Int? { get }
}

extension Claims {
    var iat: Int? {
        return nil
    }
    
    var exp: Int? {
        return nil
    }
    
    var nbf: Int? {
        return nil
    }
}
