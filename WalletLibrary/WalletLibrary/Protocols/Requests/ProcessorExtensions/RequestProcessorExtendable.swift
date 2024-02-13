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
    var associatedRequestProcessor: RequestProcessing.Type { get }
    
    /**
     * Extension to parse additional information from the request. Extensions should return an updated form of the request
     */
    func parse(rawRequest: Any, request: any VerifiedIdRequest) -> any VerifiedIdRequest
    
}
