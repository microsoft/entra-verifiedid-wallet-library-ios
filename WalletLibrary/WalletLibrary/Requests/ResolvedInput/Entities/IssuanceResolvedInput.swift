/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public class IssuanceResolvedInput: ResolvedInput {
    
    public let style: RequesterStyle
    
    public let requirement: Requirement
    
    public let rootOfTrust: RootOfTrust
    
    internal init(style: RequesterStyle, requirement: Requirement, rootOfTrust: RootOfTrust) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
    }
}
