/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct BasicServiceResponseDecoder: Decoding {
    func decode(data: Data) throws -> String? {
        return nil
    }
}

struct PresentationCompletionResponseDecoder: Decoding
{
    func decode(data: Data) throws -> SuccessfulCompletionResult
    {
        if JSONSerialization.isValidJSONObject(data)
        {
            let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return ContinuationResult(redirect_url: response?["redirect_url"] as? String)
        }
        else
        {
            return EmptyResult()
        }
    }
}

public struct ContinuationResult: SuccessfulCompletionResult
{
    public let redirect_url: String?
}
