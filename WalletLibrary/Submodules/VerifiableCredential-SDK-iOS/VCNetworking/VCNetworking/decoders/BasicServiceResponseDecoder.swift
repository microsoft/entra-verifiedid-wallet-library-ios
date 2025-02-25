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
        do
        {
            let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return ContinuationResult(redirectUri: response?["redirect_uri"] as? String)
        }
        catch
        {
            return EmptyResult()
        }
    }
}

public struct ContinuationResult: SuccessfulCompletionResult
{
    public let redirectUri: String?
}
