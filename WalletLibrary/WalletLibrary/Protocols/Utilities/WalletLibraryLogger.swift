/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Public protocol to describe a logger used in this library.
 */
public protocol WalletLibraryLogger
{
    func logVerbose(message: String,
                    functionName: String,
                    file: String,
                    line: Int)
    
    func logDebug(message: String,
                  functionName: String,
                  file: String,
                  line: Int)
    
    func logInfo(message: String,
                 functionName: String,
                 file: String,
                 line: Int)
    
    func logWarning(message: String,
                    functionName: String,
                    file: String,
                    line: Int)
    
    func logError(message: String,
                  functionName: String,
                  file: String,
                  line: Int)
    
    func logFailure(message: String,
                    functionName: String,
                    file: String,
                    line: Int)
}
