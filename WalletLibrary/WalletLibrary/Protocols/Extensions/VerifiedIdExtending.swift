/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
  * Extension to the Verified ID Wallet library
 */
protocol VerifiedIdExtnding {
    /**
     * List of prefer headers to include when resolving the request to convey extension support
     */
    var prefer: [String] { get }
    
    /**
     * List of RequestProcessorExtending to be injected into RequestProcessing classes
     */
    var requestProcessorExtensions: [RequestProcessorExtending]? { get }
}
