/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct IssuanceServiceResponse: Codable {
    public let vc: String
    
    public init(vc: String) {
        self.vc = vc
    }
}
