/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Basic Claims within a JWS token.
public protocol Claims: Codable {
    
    var iat: Double? { get }
    var exp: Double? { get }
    var nbf: Double? { get }
}

public extension Claims {
    var iat: Double? {
        return nil
    }
    
    var exp: Double? {
        return nil
    }
    
    var nbf: Double? {
        return nil
    }
}
