/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public protocol Requirement {
    var type: String { get }
    var required: Bool { get }
}

public class MockRequirement: Requirement, CustomStringConvertible {
    
    public let type: String = "mockType"
    
    public let required: Bool = true
    
    public let label = "this is a requirement"
    
    public var input: String?
    
    public func fulfill(with value: String) {
        input = value
    }
    
    public func isFulfilled() -> Bool {
        if input != nil {
            return true
        } else {
            return false
        }
    }
    
    public var description: String {
        return "MockRequirement: \n type=\(type), \n required=\(required), \n label=\(label), \n input=\(input ?? "not fulfilled")"
    }
}
