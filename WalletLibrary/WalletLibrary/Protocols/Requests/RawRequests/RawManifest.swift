/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Representation of a Raw Contract.
 * Object that conforms to this protocol must be able to map to VerifiedIdRequestContent.
 */
protocol RawManifest: RawRequest, Mappable where T == IssuanceRequestContent {}

