/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IssuanceServiceResponse: Codable {
    let vc: String
    
    init(vc: String) {
        self.vc = vc
    }
}
