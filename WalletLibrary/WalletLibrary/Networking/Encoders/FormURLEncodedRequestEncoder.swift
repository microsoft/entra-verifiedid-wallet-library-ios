/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An encoder to handle Post request bodies in the form of URLEncoded Strings.
 */
struct FormURLEncodedRequestEncoder: Encoding
{
    /// The Request Body must adhere to the `PropertyIterable` protocol.
    typealias RequestBody = PropertyIterable
    
    /// Encode the Request Body in the form of a URLEncoded String.
    func encode(value: RequestBody) throws -> Data
    {
        let encodedString = try value.allProperties().toURLEncodedString()
        
        let data = try Data.getRequiredProperty(property: encodedString.data(using: .utf8),
                                                propertyName: "encoded_string")
        
        return data
    }
}
