/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum FormatterError: Error {
    case noSigningKeyFound
    case noStateInRequest
    case unableToFormToken
    case unableToGetRawValueOfVerifiableCredential
}
