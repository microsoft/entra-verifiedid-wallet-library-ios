/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Public protocol to describe a logger used in this library.
 */
public protocol ExtensionWalletLibraryLogger
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

public extension ExtensionWalletLibraryLogger
{
    func logVerbose(message: String,
                    functionName: String = #function,
                    file: String = #file,
                    line: Int = #line)
    {
        logVerbose(message: message,
                   functionName: functionName,
                   file: file,
                   line: line)
    }
    
    func logDebug(message: String,
                  functionName: String = #function,
                  file: String = #file,
                  line: Int = #line)
    {
        logDebug(message: message,
                 functionName: functionName,
                 file: file,
                 line: line)
    }
    
    func logInfo(message: String,
                 functionName: String = #function,
                 file: String = #file,
                 line: Int = #line)
    {
        logInfo(message: message,
                functionName: functionName,
                file: file,
                line: line)
    }
    
    func logWarning(message: String,
                    functionName: String = #function,
                    file: String = #file,
                    line: Int = #line)
    {
        logWarning(message: message,
                   functionName: functionName,
                   file: file,
                   line: line)
    }
    
    func logError(message: String,
                  functionName: String = #function,
                  file: String = #file,
                  line: Int = #line)
    {
        logError(message: message,
                 functionName: functionName,
                 file: file,
                 line: line)
    }
    
    func logFailure(message: String,
                    functionName: String = #function,
                    file: String = #file,
                    line: Int = #line)
    {
        logFailure(message: message,
                   functionName: functionName,
                   file: file,
                   line: line)
    }
}
