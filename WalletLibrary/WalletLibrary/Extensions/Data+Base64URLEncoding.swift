/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


extension Data
{
    /// Converts the Data object to a base64 URL-safe string without padding characters.
    func base64URLEncodedWithNoPaddingString() -> String {
        var encodedHash = base64EncodedString()
        encodedHash = encodedHash.replacingOccurrences(of: "+", with: "-")
        encodedHash = encodedHash.replacingOccurrences(of: "/", with: "_")
        encodedHash = encodedHash.replacingOccurrences(of: "=", with: "")
        return encodedHash
    }
}
