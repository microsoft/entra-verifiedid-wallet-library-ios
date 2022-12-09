/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCServices
import VCEntities
import PromiseKit

protocol PresentationServiceable {
    func getRequest(usingUrl urlStr: String) -> Promise<PresentationRequest>
}
/**
 *
 */
extension PresentationService: PresentationServiceable { }
