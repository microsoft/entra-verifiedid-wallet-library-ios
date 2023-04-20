/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

extension URL {
    init?(unsafeString: String) {
        
        guard let safeString = unsafeString.stringByAddingPercentEncodingForRFC3986() else {
            return nil
        }
        
        self.init(string: safeString)
  }
}
