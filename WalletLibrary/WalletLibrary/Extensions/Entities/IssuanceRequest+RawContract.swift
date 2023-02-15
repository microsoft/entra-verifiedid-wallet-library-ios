/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.IssuanceRequest class.
 */
extension VCEntities.IssuanceRequest: RawContract {
    func map(using mapper: Mapping) throws -> VerifiedIdRequestContent {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
