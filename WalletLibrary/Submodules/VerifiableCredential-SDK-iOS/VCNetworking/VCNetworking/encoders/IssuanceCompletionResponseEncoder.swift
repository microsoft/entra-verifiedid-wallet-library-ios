/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct IssuanceCompletionResponseEncoder: Encoding {
    
    func encode(value: IssuanceCompletionResponse) throws -> Data {
        return try JSONEncoder().encode(value)
    }
}
