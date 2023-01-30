/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public protocol RequesterStyle {
    var requester: String { get }
}

public struct MockRequesterStyle: RequesterStyle {
    public let requester: String
}

public protocol VerifiedIdStyle {
    var title: String { get }
}

public struct MockVerifiedIdStyle: VerifiedIdStyle {
    public let title: String
}
