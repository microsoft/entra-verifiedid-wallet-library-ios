/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Extension for the RequestProcessor to add custom logic to processor.
 */
public protocol RequestProcessorExtendable 
{
    /**
     * Associated RequestProcessor this extension should be injected into.
     */
    associatedtype RequestProcessor: ExtendableRequestProcessing
    
    /**
     * Extension to parse additional information from the request. Extensions should return an updated form of the request.
     * - Parameters:
     *   - rawRequest: The associated type formed by the RequestProcessor to pass to this extension.
     *   - request: The partial request to be updated and returned.
     */
    func parse(rawRequest: RequestProcessor.RawRequestType, 
               request: VerifiedIdPartialRequest) -> VerifiedIdPartialRequest
    
}
