/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct IssuanceResponseEncoder: Encoding 
{
    func encode(value: IssuanceResponse) throws -> Data 
    {
        let encodedToken = try Data.getRequiredProperty(property: try value.serialize().data(using: .ascii),
                                                        propertyName: "encodedToken")
        
        return encodedToken
    }
}
