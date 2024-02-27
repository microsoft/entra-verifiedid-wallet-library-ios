/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
  * Extension for the RequestProcessor
 */
public protocol RequestProcessorExtendable {
    /**
     * Associated RequestProcessor this extension should be injected into
     */
    associatedtype RequestProcessor : RequestProcessing
    
    /**
     * Extension to parse additional information from the request. Extensions should return an updated form of the request
     */
    func parse(rawRequest: RequestProcessor.RawRequestType, request: VerifiedIdPartialRequest) -> VerifiedIdPartialRequest
    
}
