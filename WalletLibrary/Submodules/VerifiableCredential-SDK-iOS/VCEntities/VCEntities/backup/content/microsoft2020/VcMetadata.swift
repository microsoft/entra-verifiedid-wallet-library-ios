/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

open class VcMetadata : Codable {

    public var displayContract: DisplayDescriptor?
    public var type: String
    
    public init(as type:String) {
        self.type = type
    }
}
